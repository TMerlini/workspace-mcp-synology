# Google Workspace MCP - Coolify Edition

This repository is configured for easy deployment to Coolify on your NAS.

## What's Included

- ✅ **Dockerfile** - Optimized for container deployment
- ✅ **docker-compose.coolify.yml** - Coolify-specific compose file
- ✅ **.env.coolify** - Environment variable template
- ✅ **QUICKSTART_COOLIFY.md** - 5-minute deployment guide
- ✅ **COOLIFY_DEPLOYMENT.md** - Comprehensive deployment documentation

## Quick Links

- **Quick Start**: [QUICKSTART_COOLIFY.md](./QUICKSTART_COOLIFY.md) - Get running in 5 minutes
- **Full Guide**: [COOLIFY_DEPLOYMENT.md](./COOLIFY_DEPLOYMENT.md) - Complete deployment documentation
- **Original README**: [README.md](./README.md) - Full project documentation

## What is This?

Google Workspace MCP Server provides AI assistants with full access to:
- 📧 Gmail - Email management
- 📁 Google Drive - File operations
- 📅 Google Calendar - Event management
- 📝 Google Docs - Document editing
- 📊 Google Sheets - Spreadsheet operations
- 🖼️ Google Slides - Presentation management
- 📋 Google Forms - Form creation and responses
- ✅ Google Tasks - Task management
- 👤 Google Contacts - Contact management
- 💬 Google Chat - Messaging and spaces
- ⚡ Apps Script - Automation
- 🔍 Custom Search - Web search

## Why Coolify?

Coolify makes it easy to:
- 🚀 Deploy with one click
- 🔒 Automatic HTTPS with Let's Encrypt
- 📊 Built-in monitoring and logs
- 🔄 Easy updates and rollbacks
- 💾 Persistent storage management
- 🌐 Domain management

## Architecture

```
┌─────────────────┐
│   AI Assistant  │ (Claude, VS Code, etc.)
└────────┬────────┘
         │ HTTPS
         ▼
┌─────────────────┐
│  Coolify Proxy  │ (Automatic HTTPS)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  MCP Server     │ (This container)
│  Port 8000      │
└────────┬────────┘
         │ OAuth 2.1
         ▼
┌─────────────────┐
│  Google APIs    │
└─────────────────┘
```

## Configuration Options

### Tool Tiers

Choose your feature level:

- **core** - Essential tools only (recommended to start)
- **extended** - Core + management features
- **complete** - All available tools

Set in Coolify: `TOOL_TIER=core`

### Specific Services

Or select only what you need:

Set in Coolify: `TOOLS=gmail drive calendar`

### Storage Backends

Choose how OAuth tokens are stored:

- **memory** - Fast, no persistence (default in stateless mode)
- **disk** - Persists across restarts (good for single server)
- **valkey/redis** - Distributed storage (for multi-server)

Set in Coolify: `WORKSPACE_MCP_OAUTH_PROXY_STORAGE_BACKEND=disk`

## Security Features

- ✅ OAuth 2.1 multi-user authentication
- ✅ Stateless mode (no local file writes)
- ✅ HTTPS enforced (via Coolify)
- ✅ Token encryption
- ✅ Scope minimization
- ✅ Health check endpoints

## Environment Variables Reference

### Required

```bash
GOOGLE_OAUTH_CLIENT_ID          # From Google Cloud Console
GOOGLE_OAUTH_CLIENT_SECRET      # From Google Cloud Console
MCP_ENABLE_OAUTH21              # Set to: true
WORKSPACE_MCP_STATELESS_MODE    # Set to: true
WORKSPACE_EXTERNAL_URL          # Your Coolify domain
```

### Optional

```bash
TOOL_TIER                       # core, extended, or complete
TOOLS                           # Comma-separated service list
WORKSPACE_MCP_PORT              # Default: 8000
GOOGLE_PSE_API_KEY              # For custom search
GOOGLE_PSE_ENGINE_ID            # For custom search
```

See `.env.coolify` for complete list.

## Getting Started

1. **Read the Quick Start**: [QUICKSTART_COOLIFY.md](./QUICKSTART_COOLIFY.md)
2. **Get Google credentials** (2 minutes)
3. **Deploy to Coolify** (3 minutes)
4. **Connect your AI assistant**

## Support & Resources

- **Issues**: https://github.com/taylorwilsdon/google_workspace_mcp/issues
- **MCP Docs**: https://modelcontextprotocol.io/
- **Coolify Docs**: https://coolify.io/docs
- **Original Project**: https://github.com/taylorwilsdon/google_workspace_mcp

## License

MIT License - see [LICENSE](./LICENSE) file for details.

## Credits

- Original project by [taylorwilsdon](https://github.com/taylorwilsdon)
- Coolify configuration and documentation for NAS deployment

---

**Ready to deploy?** → [QUICKSTART_COOLIFY.md](./QUICKSTART_COOLIFY.md)
