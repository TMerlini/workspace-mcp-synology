# Quick Start: Deploy to Coolify in 5 Minutes

## Before You Start

You need:
1. ✅ Coolify installed on your NAS
2. ✅ Google Cloud account
3. ✅ 5 minutes

## Step 1: Get Google Credentials (2 minutes)

1. Go to https://console.cloud.google.com/
2. Create a new project (or select existing)
3. Click **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth Client ID**
5. Choose **Desktop Application**
6. Copy your **Client ID** and **Client Secret**

### Enable APIs (click each link):
- [Gmail](https://console.cloud.google.com/flows/enableapi?apiid=gmail.googleapis.com)
- [Drive](https://console.cloud.google.com/flows/enableapi?apiid=drive.googleapis.com)
- [Calendar](https://console.cloud.google.com/flows/enableapi?apiid=calendar-json.googleapis.com)
- [Docs](https://console.cloud.google.com/flows/enableapi?apiid=docs.googleapis.com)
- [Sheets](https://console.cloud.google.com/flows/enableapi?apiid=sheets.googleapis.com)

## Step 2: Deploy to Coolify (3 minutes)

### 2.1 Create New Resource

1. Open Coolify dashboard
2. Click **+ New Resource**
3. Select **Git Repository**
4. Enter: `https://github.com/taylorwilsdon/google_workspace_mcp.git`
5. Branch: `main`

### 2.2 Configure

**Build Settings:**
- Build Method: `Dockerfile`
- Dockerfile: `./Dockerfile`

**Port:**
- Container Port: `8000`

**Environment Variables** (click "Add Variable" for each):

```
GOOGLE_OAUTH_CLIENT_ID=your-client-id-here
GOOGLE_OAUTH_CLIENT_SECRET=your-client-secret-here
MCP_ENABLE_OAUTH21=true
WORKSPACE_MCP_STATELESS_MODE=true
WORKSPACE_MCP_HOST=0.0.0.0
WORKSPACE_MCP_PORT=8000
TOOL_TIER=core
```

### 2.3 Deploy

1. Click **Deploy**
2. Wait for build (2-3 minutes)
3. Copy your assigned URL (e.g., `https://xyz.coolify.io`)

### 2.4 Update External URL

1. Add one more environment variable:
   ```
   WORKSPACE_EXTERNAL_URL=https://your-assigned-url.coolify.io
   ```
2. Click **Redeploy**

## Step 3: Test It

Visit: `https://your-url.coolify.io/health`

You should see: `{"status": "ok"}` or similar

## Step 4: Connect a Client

### Claude Code

```bash
claude mcp add --transport http workspace-mcp https://your-url.coolify.io/mcp
```

### VS Code MCP

Add to settings:
```json
{
    "servers": {
        "google-workspace": {
            "url": "https://your-url.coolify.io/mcp",
            "type": "http"
        }
    }
}
```

## Done! 🎉

Try asking your AI assistant:
- "List my recent emails"
- "Show my calendar for today"
- "Search my Drive for documents about X"

## Troubleshooting

**Build fails?**
- Check Coolify logs
- Verify all environment variables are set

**OAuth errors?**
- Make sure `WORKSPACE_EXTERNAL_URL` matches your actual URL
- Check that APIs are enabled in Google Cloud

**Can't connect?**
- Verify HTTPS is enabled in Coolify
- Check firewall settings on your NAS

## Need More Help?

See the full guide: [COOLIFY_DEPLOYMENT.md](./COOLIFY_DEPLOYMENT.md)
