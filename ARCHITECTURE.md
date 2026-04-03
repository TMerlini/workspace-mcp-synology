# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet / Users                        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ HTTPS
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    Coolify Reverse Proxy                     │
│                  (Automatic HTTPS/SSL)                       │
│                                                              │
│  Features:                                                   │
│  • Let's Encrypt SSL certificates                           │
│  • Domain management                                         │
│  • Load balancing                                            │
│  • Health checks                                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ HTTP (internal)
                            │
┌───────────────────────────▼─────────────────────────────────┐
│              Google Workspace MCP Server                     │
│                    (Docker Container)                        │
│                                                              │
│  Components:                                                 │
│  • FastMCP Server (Python)                                   │
│  • OAuth 2.1 Handler                                         │
│  • Service Managers (Gmail, Drive, etc.)                     │
│  • Token Storage (Memory/Disk/Redis)                         │
│                                                              │
│  Port: 8000                                                  │
│  Mode: Stateless                                             │
│  Auth: OAuth 2.1                                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ OAuth 2.1 / API Calls
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    Google Cloud APIs                         │
│                                                              │
│  • Gmail API                                                 │
│  • Drive API                                                 │
│  • Calendar API                                              │
│  • Docs API                                                  │
│  • Sheets API                                                │
│  • And 7 more...                                             │
└──────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Client Connection

```
AI Assistant (Claude, VS Code, etc.)
    │
    │ 1. Connect to MCP endpoint
    │    https://your-domain.coolify.io/mcp
    │
    ▼
MCP Server
    │
    │ 2. Return available tools
    │
    ▼
AI Assistant
```

### 2. Tool Invocation (First Time)

```
AI Assistant
    │
    │ 1. Call tool (e.g., "list_gmail_messages")
    │
    ▼
MCP Server
    │
    │ 2. No auth token → Return OAuth URL
    │
    ▼
AI Assistant → User
    │
    │ 3. User opens OAuth URL in browser
    │
    ▼
Google OAuth
    │
    │ 4. User authenticates
    │
    ▼
MCP Server
    │
    │ 5. Receive token, store encrypted
    │ 6. Execute original tool call
    │
    ▼
Google API
    │
    │ 7. Return data
    │
    ▼
AI Assistant
```

### 3. Subsequent Tool Calls

```
AI Assistant
    │
    │ 1. Call tool with Bearer token
    │
    ▼
MCP Server
    │
    │ 2. Validate token (cached)
    │ 3. Execute tool call
    │
    ▼
Google API
    │
    │ 4. Return data
    │
    ▼
AI Assistant
```

## Storage Architecture

### Option 1: Stateless Mode (Recommended for Coolify)

```
┌──────────────────┐
│   MCP Server     │
│                  │
│  Token Storage:  │
│  • Memory only   │
│  • No disk I/O   │
│  • Ephemeral     │
│                  │
│  Pros:           │
│  • Container-    │
│    friendly      │
│  • Fast          │
│  • No volumes    │
│                  │
│  Cons:           │
│  • Re-auth after │
│    restart       │
└──────────────────┘
```

### Option 2: Disk Storage

```
┌──────────────────┐
│   MCP Server     │
│                  │
│  Token Storage:  │
│  • Disk-backed   │
│  • Encrypted     │
│  • Persistent    │
│                  │
│  Volume:         │
│  /app/store_creds│
│                  │
│  Pros:           │
│  • Survives      │
│    restarts      │
│  • No re-auth    │
│                  │
│  Cons:           │
│  • Needs volume  │
│  • Single server │
└──────────────────┘
```

### Option 3: Redis/Valkey (Advanced)

```
┌──────────────────┐     ┌──────────────────┐
│   MCP Server     │────▶│  Redis/Valkey    │
│                  │     │                  │
│  Token Storage:  │     │  • Distributed   │
│  • Redis client  │     │  • Encrypted     │
│  • Networked     │     │  • Persistent    │
│                  │     │  • Multi-server  │
│  Pros:           │     │                  │
│  • Distributed   │     └──────────────────┘
│  • Scalable      │
│  • HA support    │
│                  │
│  Cons:           │
│  • More complex  │
│  • Needs Redis   │
└──────────────────┘
```

## Security Layers

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Transport Security                                 │
│  • HTTPS (TLS 1.2+)                                          │
│  • Automatic SSL via Coolify/Let's Encrypt                   │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Authentication                                     │
│  • OAuth 2.1 Bearer tokens                                   │
│  • Google OAuth validation                                   │
│  • Token expiry enforcement                                  │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: Authorization                                      │
│  • Google OAuth scopes                                       │
│  • Per-service permissions                                   │
│  • Scope minimization                                        │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: Data Protection                                    │
│  • Token encryption (Fernet)                                 │
│  • No plaintext credentials                                  │
│  • Secure key derivation                                     │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Topology

### Single Server (Recommended for NAS)

```
┌────────────────────────────────────────────┐
│              Your NAS                      │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │         Coolify                      │ │
│  │                                      │ │
│  │  ┌────────────────────────────────┐ │ │
│  │  │  MCP Container                 │ │ │
│  │  │  • Port 8000                   │ │ │
│  │  │  • Stateless mode              │ │ │
│  │  │  • Memory storage              │ │ │
│  │  └────────────────────────────────┘ │ │
│  │                                      │ │
│  │  ┌────────────────────────────────┐ │ │
│  │  │  Reverse Proxy                 │ │ │
│  │  │  • HTTPS                       │ │ │
│  │  │  • Domain routing              │ │ │
│  │  └────────────────────────────────┘ │ │
│  └──────────────────────────────────────┘ │
└────────────────────────────────────────────┘
```

### With Persistent Storage

```
┌────────────────────────────────────────────┐
│              Your NAS                      │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │         Coolify                      │ │
│  │                                      │ │
│  │  ┌────────────────────────────────┐ │ │
│  │  │  MCP Container                 │ │ │
│  │  │  • Port 8000                   │ │ │
│  │  │  • Disk storage                │ │ │
│  │  │                                │ │ │
│  │  │  Volume Mount:                 │ │ │
│  │  │  /app/store_creds ──────────┐  │ │ │
│  │  └──────────────────────────────│──┘ │ │
│  │                                 │    │ │
│  │  ┌──────────────────────────────▼──┐ │ │
│  │  │  NAS Storage                   │ │ │
│  │  │  /volume1/docker/workspace-mcp │ │ │
│  │  └────────────────────────────────┘ │ │
│  └──────────────────────────────────────┘ │
└────────────────────────────────────────────┘
```

## Network Flow

```
Internet
    │
    │ Port 443 (HTTPS)
    │
    ▼
Your Router/Firewall
    │
    │ Port forwarding
    │
    ▼
NAS (Coolify)
    │
    │ Reverse proxy
    │
    ▼
MCP Container (Port 8000)
    │
    │ Outbound HTTPS
    │
    ▼
Google APIs (Internet)
```

## Tool Tier Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  TOOL_TIER=complete (All Tools)                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  TOOL_TIER=extended (Core + Management)                 ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │  TOOL_TIER=core (Essential Only)                    │││
│  │  │                                                      │││
│  │  │  • search_gmail_messages                            │││
│  │  │  • get_gmail_message_content                        │││
│  │  │  • send_gmail_message                               │││
│  │  │  • search_drive_files                               │││
│  │  │  • get_drive_file_content                           │││
│  │  │  • create_drive_file                                │││
│  │  │  • get_events                                       │││
│  │  │  • manage_event                                     │││
│  │  │  • ... (essential tools)                            │││
│  │  │                                                      │││
│  │  └──────────────────────────────────────────────────────┘││
│  │                                                          ││
│  │  + list_gmail_labels                                    ││
│  │  + modify_gmail_message_labels                          ││
│  │  + list_drive_items                                     ││
│  │  + manage_drive_access                                  ││
│  │  + ... (management tools)                               ││
│  │                                                          ││
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
│  + list_document_comments                                   │
│  + manage_document_comment                                  │
│  + batch_update_doc                                         │
│  + ... (advanced tools)                                     │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Scaling Considerations

### Current Setup (Single Server)
- ✅ Perfect for personal/small team use
- ✅ Simple to manage
- ✅ Low resource requirements
- ✅ Works great on NAS

### Future Scaling Options
- Add Redis for distributed storage
- Deploy multiple containers behind load balancer
- Use external OAuth provider
- Implement rate limiting
- Add caching layer

## Monitoring Points

```
┌──────────────────┐
│  Coolify         │
│  • Container     │
│    health        │
│  • Resource      │
│    usage         │
│  • Logs          │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  MCP Server      │
│  • /health       │
│    endpoint      │
│  • API response  │
│    times         │
│  • Error rates   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Google APIs     │
│  • Quota usage   │
│  • API errors    │
│  • Rate limits   │
└──────────────────┘
```

---

This architecture provides a secure, scalable foundation for running the Google Workspace MCP server on your NAS with Coolify.
