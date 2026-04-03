# Google Workspace MCP for Synology NAS / Coolify

[![Deploy to Coolify](https://img.shields.io/badge/Deploy%20to-Coolify-blue)](https://coolify.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](./Dockerfile)

> **Coolify-optimized deployment** of the Google Workspace MCP Server for Synology NAS and other self-hosted environments.

## 🚀 Quick Deploy to Coolify

**Total Time: 5 minutes**

1. **Get Google OAuth credentials** (2 min) - [Guide](./QUICKSTART_COOLIFY.md#step-1-get-google-credentials-2-minutes)
2. **Create resource in Coolify** - Point to this repository
3. **Set environment variables** - Copy from [.env.coolify](./.env.coolify)
4. **Deploy** - Click deploy and wait 2-3 minutes
5. **Update external URL** - Add your Coolify domain
6. **Done!** - Connect your AI assistant

📖 **Full Guide:** [QUICKSTART_COOLIFY.md](./QUICKSTART_COOLIFY.md)

## 📋 What This Is

This repository is a **deployment-ready fork** of the [Google Workspace MCP Server](https://github.com/taylorwilsdon/google_workspace_mcp) optimized for:

- 🏠 **Synology NAS** deployment
- 🐳 **Coolify** container management
- 🔒 **Self-hosted** environments
- 🌐 **Multi-user** OAuth 2.1 support
- 📦 **Stateless** container mode

### Services Supported

Give your AI assistants access to:

| Service | Features |
|---------|----------|
| 📧 **Gmail** | Read, send, search, manage emails |
| 📁 **Google Drive** | Access, create, share files |
| 📅 **Google Calendar** | View, create, manage events |
| 📝 **Google Docs** | Read, edit documents |
| 📊 **Google Sheets** | Manage spreadsheets |
| 🖼️ **Google Slides** | Create presentations |
| 📋 **Google Forms** | Create and manage forms |
| ✅ **Google Tasks** | Task management |
| 👤 **Google Contacts** | Contact management |
| 💬 **Google Chat** | Messaging and spaces |
| ⚡ **Apps Script** | Automation workflows |
| 🔍 **Custom Search** | Web search integration |

## 🎯 Why This Fork?

This repository adds:

- ✅ **Coolify deployment guides** - Step-by-step instructions
- ✅ **Synology NAS optimization** - Container-friendly configuration
- ✅ **Environment templates** - Pre-configured `.env` files
- ✅ **Docker Compose files** - Coolify-optimized setup
- ✅ **Comprehensive documentation** - Quick start + detailed guides
- ✅ **Deployment checklists** - Ensure nothing is missed
- ✅ **Architecture diagrams** - Understand the system

## 📚 Documentation

| Document | Purpose | Time |
|----------|---------|------|
| [START_HERE.md](./START_HERE.md) | Entry point | 1 min |
| [QUICKSTART_COOLIFY.md](./QUICKSTART_COOLIFY.md) | Fast deployment | 5 min |
| [COOLIFY_DEPLOYMENT.md](./COOLIFY_DEPLOYMENT.md) | Complete guide | 15 min |
| [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md) | Step tracker | 10 min |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System design | 5 min |

## 🔧 Configuration

### Required Environment Variables

```bash
# Google OAuth (from Google Cloud Console)
GOOGLE_OAUTH_CLIENT_ID=your-client-id
GOOGLE_OAUTH_CLIENT_SECRET=your-secret

# OAuth 2.1 Multi-User Support
MCP_ENABLE_OAUTH21=true

# Stateless Container Mode
WORKSPACE_MCP_STATELESS_MODE=true

# External URL (from Coolify)
WORKSPACE_EXTERNAL_URL=https://your-domain.coolify.io
```

See [.env.coolify](./.env.coolify) for all options.

## 🏗️ Architecture

```
Internet → Coolify (HTTPS) → MCP Container → Google APIs
```

- **Transport:** HTTP with OAuth 2.1
- **Authentication:** Bearer tokens
- **Storage:** Memory (stateless) or Disk/Redis (persistent)
- **Port:** 8000

Full architecture: [ARCHITECTURE.md](./ARCHITECTURE.md)

## 🔐 Security

- ✅ OAuth 2.1 authentication
- ✅ HTTPS enforced via Coolify
- ✅ Token encryption (Fernet)
- ✅ Stateless mode (no disk writes)
- ✅ Scope minimization
- ✅ Multi-user isolation

## 🚦 Getting Started

### Prerequisites

- Coolify installed on your NAS
- Google Cloud account (free tier works)
- Domain or subdomain (Coolify can provide)

### Quick Start

1. **Clone or fork this repository**
2. **Follow [QUICKSTART_COOLIFY.md](./QUICKSTART_COOLIFY.md)**
3. **Deploy in 5 minutes**

### Detailed Setup

1. **Read [START_HERE.md](./START_HERE.md)**
2. **Follow [COOLIFY_DEPLOYMENT.md](./COOLIFY_DEPLOYMENT.md)**
3. **Use [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)**

## 🎛️ Tool Tiers

Choose your feature level:

| Tier | Tools | Use Case |
|------|-------|----------|
| **core** | Essential only | Getting started, light usage |
| **extended** | Core + management | Regular usage, more features |
| **complete** | All tools | Power users, full access |

Set in Coolify: `TOOL_TIER=core`

Or select specific services: `TOOLS=gmail drive calendar`

## 🔌 Connect Clients

### Claude Code

```bash
claude mcp add --transport http workspace-mcp https://your-domain.coolify.io/mcp
```

### VS Code MCP

```json
{
    "servers": {
        "google-workspace": {
            "url": "https://your-domain.coolify.io/mcp",
            "type": "http"
        }
    }
}
```

### MCP Inspector

```bash
npx @modelcontextprotocol/inspector https://your-domain.coolify.io/mcp
```

## 📦 Deployment Options

### Option 1: Coolify (Recommended)

- One-click deployment
- Automatic HTTPS
- Built-in monitoring
- Easy updates

### Option 2: Docker Compose

```bash
docker-compose -f docker-compose.coolify.yml up -d
```

### Option 3: Plain Docker

```bash
docker build -t workspace-mcp .
docker run -p 8000:8000 --env-file .env workspace-mcp
```

## 🛠️ Maintenance

### Updating

In Coolify, click **Redeploy** to pull latest changes.

### Monitoring

- Health endpoint: `https://your-domain/health`
- Coolify dashboard for logs and metrics
- Google Cloud Console for API quotas

### Backup

If using persistent storage:
- Backup `/app/store_creds` volume
- Backup `.env` configuration
- Keep OAuth credentials secure

## 🆘 Troubleshooting

### Common Issues

**Build fails:**
- Check Coolify logs
- Verify all environment variables are set

**OAuth errors:**
- Ensure `WORKSPACE_EXTERNAL_URL` matches your domain
- Check APIs are enabled in Google Cloud

**Can't connect:**
- Verify HTTPS is enabled
- Check firewall settings
- Test health endpoint

See [COOLIFY_DEPLOYMENT.md](./COOLIFY_DEPLOYMENT.md#troubleshooting) for detailed troubleshooting.

## 🤝 Contributing

This is a deployment-focused fork. For core features:
- **Upstream:** [taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp)
- **Issues:** Report deployment issues here, core issues upstream

## 📄 License

MIT License - see [LICENSE](./LICENSE)

## 🙏 Credits

- **Original Project:** [taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp)
- **Coolify:** [coolify.io](https://coolify.io)
- **MCP Protocol:** [modelcontextprotocol.io](https://modelcontextprotocol.io)

## 🔗 Links

- **Documentation:** [START_HERE.md](./START_HERE.md)
- **Quick Start:** [QUICKSTART_COOLIFY.md](./QUICKSTART_COOLIFY.md)
- **Architecture:** [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Original Project:** [github.com/taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp)
- **Coolify Docs:** [coolify.io/docs](https://coolify.io/docs)
- **MCP Docs:** [modelcontextprotocol.io](https://modelcontextprotocol.io)

---

**Ready to deploy?** → [QUICKSTART_COOLIFY.md](./QUICKSTART_COOLIFY.md) 🚀
