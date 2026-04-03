# Google Workspace MCP — Synology NAS + n8n Integration

This document covers the production deployment on a Synology DS1522+ NAS using Coolify, with an n8n webhook acting as a universal Google Workspace action endpoint, and full integration into a Telegram AI assistant pipeline.

## Architecture

```
Telegram / Any HTTP Client
        │
        ▼
POST https://n8n.gen-plasma.com/webhook/workspace-action
        │
        ▼  (n8n workflow: "Echo — Google Workspace Action")
        │
        ├─► GET http://<mac-mini>:7078/workspace-token   ← token proxy, rotates refresh_token
        │         (reads/writes ~/.claude/workspace_mcp_creds.json)
        │
        ├─► POST https://workspace-mcp.gen-plasma.com/mcp   ← MCP initialize (get session ID)
        │
        └─► POST https://workspace-mcp.gen-plasma.com/mcp   ← tools/call with session ID
                  │
                  └─► Google APIs (Calendar, Gmail, Drive, etc.)
```

### Telegram AI Pipeline (full)

```
Telegram message (text / voice / photo)
        │
        ▼
n8n "Echo — Telegram Webhook" (wRGXyh4qISbrOLVB)
        │
        ├─ voice → download → transcribe (whisper, Mac mini :7078)
        ├─ photo → capture file_id → download as base64 in Code node
        └─ text  → pass through
        │
        ▼
Prepare Message → Get Context (:7078) → Get History (:7078)
        │
        ▼
Ask Claude (Code node, claude-sonnet-4-6)
  ├─ text messages → direct Claude call
  ├─ photo messages → base64 image block + text caption
  └─ Google Workspace requests → tool_use → POST /webhook/workspace-action → tool_result → Claude
        │
        ▼
Send Text Reply (always) → if voice: Send Voice Reply (:7078/speak) → Save History
```

## Deployment on Synology + Coolify

### workspace-mcp service

- **Image**: Built from this repo via Coolify
- **URL**: `https://workspace-mcp.gen-plasma.com`
- **Port**: 8000 (internal)
- **Network**: `coolify` Docker network

**Required environment variables in Coolify:**
```
GOOGLE_OAUTH_CLIENT_ID=<your-oauth-client-id>.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_SECRET=<your-oauth-client-secret>
MCP_ENABLE_OAUTH21=true
WORKSPACE_MCP_STATELESS_MODE=true
WORKSPACE_EXTERNAL_URL=https://workspace-mcp.gen-plasma.com
WORKSPACE_MCP_HOST=0.0.0.0
WORKSPACE_MCP_PORT=8000
TOOL_TIER=all
GOOGLE_MCP_CREDENTIALS_DIR=/app/store_creds
```

### Traefik routing

Add `/volume1/docker/ECHO/data/coolify/proxy/dynamic/workspace-mcp.yaml`:
```yaml
http:
  routers:
    workspace-mcp-public:
      entryPoints:
        - http
      rule: "Host(`workspace-mcp.gen-plasma.com`)"
      service: http-0-<coolify-uuid>@docker
      priority: 200
```

Use the Docker service reference (`serviceName@docker`) — stable across container IP changes.

### OAuth setup (first-time)

1. Call `GET https://workspace-mcp.gen-plasma.com/oauth/register`
2. Complete Google sign-in and grant all required scopes
3. Save the returned `refresh_token` and `client_id` to `~/.claude/workspace_mcp_creds.json`

> **Token rotation**: workspace-mcp rotates refresh tokens on every use.
> The token proxy at `:7078/workspace-token` handles rotation atomically.
> **Never call `/token` directly** — use the proxy.

## n8n Webhook (workspace-action)

**Endpoint**: `POST https://n8n.gen-plasma.com/webhook/workspace-action`

**Request body:**
```json
{
  "tool": "get_events",
  "params": {"calendar_id": "primary", "time_min": "2026-04-03T00:00:00+01:00", "time_max": "2026-04-03T23:59:59+01:00"}
}
```

**Response:**
```json
{
  "tool": "get_events",
  "content": "Successfully retrieved 10 events...",
  "isError": false
}
```

### Actual MCP tool names (use these exactly)

The MCP tool names differ from generic Google API names:

| Category | Tool name |
|---|---|
| Calendar | `list_calendars`, `get_events`, `manage_event`, `query_freebusy` |
| Gmail | `search_gmail_messages`, `get_gmail_message_content`, `send_gmail_message`, `draft_gmail_message` |
| Drive | `list_drive_items`, `search_drive_files`, `get_drive_file_content` |
| Tasks | `list_task_lists`, `list_tasks`, `manage_task` |
| Docs | `search_docs`, `get_doc_as_markdown` |

**`manage_event` parameters:**
```json
{
  "action": "create",
  "calendar_id": "primary",
  "summary": "Event title",
  "start_time": "2026-04-04T10:00:00+01:00",
  "end_time": "2026-04-04T11:00:00+01:00"
}
```
> `start_time` and `end_time` are **flat ISO 8601 strings** — not nested `{"dateTime": "..."}` objects.

**Known limitations:**
- `send_gmail_message`: plain text only, no attachments

## n8n Ask Claude Code Node

The Telegram pipeline uses a Code node (not HTTP Request) for Claude to avoid n8n template delimiter issues and support tool use loops. Key details:

- Model: `claude-sonnet-4-6` (Sonnet handles tool use more reliably than Haiku)
- Body passed as plain JS object with `json: true` — NOT `JSON.stringify()` (causes double-encoding)
- Image support: downloads Telegram photo as arraybuffer → base64 → Claude image block
- Tool use: single round — Claude calls tool → workspace webhook → tool_result → final response
- History: plain array `[{role, content}]` in `~/.claude/telegram_history.json`

## Token Proxy (Mac mini)

The token proxy runs on the Mac mini at port 7078 as part of `transcription_server.py`.

`GET http://<mac-mini>:7078/workspace-token` — reads `workspace_mcp_creds.json`, calls
`workspace-mcp.gen-plasma.com/token` with the refresh token, saves the rotated refresh
token back, and returns the access token to the caller.

**Never call `workspace-mcp.gen-plasma.com/token` directly** — this will consume the
refresh token without saving the rotation, leaving `workspace_mcp_creds.json` stale.

## Workflow Backups

Both n8n workflows are backed up (credentials redacted) in `n8n-workflows/`:
- `telegram_webhook_wf.json` — Echo — Telegram Webhook
- `workspace_action_wf.json` — Echo — Google Workspace Action

Live backups (with credentials) are at `/volume1/docker/ECHO/data/n8n-backups/` on the NAS.

## Recovery after workspace-mcp redeploy

The OAuth client registration and JTI state live in the container's `/app/store_creds/`.
If the container is redeployed without a persistent volume, re-register:

1. Call `GET https://workspace-mcp.gen-plasma.com/oauth/register`
2. Complete OAuth flow
3. Update `~/.claude/workspace_mcp_creds.json` with new `client_id` and `refresh_token`
4. Update `token_endpoint` and `endpoint` fields if needed
