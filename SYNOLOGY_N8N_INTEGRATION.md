# Google Workspace MCP — Synology NAS + n8n Integration

This document covers the production deployment on a Synology DS1522+ NAS using Coolify, with an n8n webhook acting as a universal Google Workspace action endpoint.

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

### Traefik routing (dynamic config)

Add `/volume1/docker/ECHO/data/coolify/proxy/dynamic/workspace-mcp.yaml`:
```yaml
http:
  routers:
    workspace-mcp-public:
      entryPoints:
        - http
      rule: "Host(`workspace-mcp.gen-plasma.com`)"
      service: workspace-mcp-backend
      priority: 200

  services:
    workspace-mcp-backend:
      loadBalancer:
        servers:
          - url: http://<container-ip>:8000
```

> **Note**: After each Coolify redeploy the container IP changes. Check with:
> `docker inspect <container-id> | grep IPAddress`

### OAuth setup (first-time)

1. Register a client via the OAuth 2.1 flow:
   ```
   GET https://workspace-mcp.gen-plasma.com/oauth/register
   ```
2. Complete Google sign-in, grant all required scopes
3. Save the returned `refresh_token` and `client_id` to:
   `~/.claude/workspace_mcp_creds.json`

> **Token rotation**: workspace-mcp rotates refresh tokens on every use.
> The token proxy at `:7078/workspace-token` handles rotation atomically.

## n8n Webhook

**Endpoint**: `POST https://n8n.gen-plasma.com/webhook/workspace-action`

**Request body:**
```json
{
  "tool": "list_calendars",
  "params": {}
}
```

**Response:**
```json
{
  "tool": "list_calendars",
  "content": "Successfully listed 5 calendars...",
  "isError": false
}
```

**Available tools** (subset):
- `list_calendars`, `get_events`, `create_event`
- `search_gmail_messages`, `get_email`, `send_email`, `create_draft`
- `list_drive_files`, `get_file_content`
- `list_tasks`, `create_task`

> **Gmail API**: must be enabled in the GCP project linked to your OAuth credentials.
> Enable at: https://console.cloud.google.com/flows/enableapi?apiid=gmail.googleapis.com

## Token Proxy (Mac mini)

The token proxy runs on the Mac mini at port 7078 as part of `transcription_server.py`.

`GET http://<mac-mini>:7078/workspace-token` — reads `workspace_mcp_creds.json`, calls
`workspace-mcp.gen-plasma.com/token` with the refresh token, saves the rotated refresh
token back, and returns the access token to the caller.

**Never call `workspace-mcp.gen-plasma.com/token` directly** — this will consume the
refresh token without saving the rotation, leaving `workspace_mcp_creds.json` stale.

## Recovery after workspace-mcp redeploy

The OAuth client registration and JTI state live in the container's `/app/store_creds/`.
If the container is redeployed without a persistent volume, re-register:

1. Call `GET https://workspace-mcp.gen-plasma.com/oauth/register`
2. Complete OAuth flow
3. Update `~/.claude/workspace_mcp_creds.json` with new `client_id` and `refresh_token`
4. Update `token_endpoint` and `endpoint` fields if needed
