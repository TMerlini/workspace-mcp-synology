# Google Workspace MCP - Coolify Deployment Guide

This guide will help you deploy the Google Workspace MCP server on Coolify running on your NAS.

## Prerequisites

1. **Coolify installed** on your NAS
2. **Google Cloud Project** with OAuth credentials
3. **Domain name** (or subdomain) pointed to your NAS

## Step 1: Google Cloud Setup

### 1.1 Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID

### 1.2 Enable Required APIs

Enable the following APIs in your project:
- [Gmail API](https://console.cloud.google.com/flows/enableapi?apiid=gmail.googleapis.com)
- [Google Drive API](https://console.cloud.google.com/flows/enableapi?apiid=drive.googleapis.com)
- [Google Calendar API](https://console.cloud.google.com/flows/enableapi?apiid=calendar-json.googleapis.com)
- [Google Docs API](https://console.cloud.google.com/flows/enableapi?apiid=docs.googleapis.com)
- [Google Sheets API](https://console.cloud.google.com/flows/enableapi?apiid=sheets.googleapis.com)
- [Google Slides API](https://console.cloud.google.com/flows/enableapi?apiid=slides.googleapis.com)
- [Google Forms API](https://console.cloud.google.com/flows/enableapi?apiid=forms.googleapis.com)
- [Google Tasks API](https://console.cloud.google.com/flows/enableapi?apiid=tasks.googleapis.com)
- [Google Chat API](https://console.cloud.google.com/flows/enableapi?apiid=chat.googleapis.com)
- [People API](https://console.cloud.google.com/flows/enableapi?apiid=people.googleapis.com)
- [Apps Script API](https://console.cloud.google.com/flows/enableapi?apiid=script.googleapis.com)

### 1.3 Create OAuth 2.0 Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth Client ID**
3. Choose **Desktop Application** (no redirect URIs needed!)
4. Download the credentials or copy:
   - Client ID
   - Client Secret

## Step 2: Coolify Setup

### 2.1 Create New Resource in Coolify

1. Log into your Coolify dashboard
2. Click **+ New Resource**
3. Select **Docker Compose** or **Dockerfile**
4. Choose **Git Repository** as source
5. Enter repository URL: `https://github.com/taylorwilsdon/google_workspace_mcp.git`
6. Select branch: `main`

### 2.2 Configure Build Settings

**Build Method:** Dockerfile
**Dockerfile Location:** `./Dockerfile`
**Build Context:** `.`

### 2.3 Configure Port Mapping

**Container Port:** `8000`
**Public Port:** Let Coolify assign automatically

### 2.4 Configure Environment Variables

In Coolify's environment variables section, add the following:

#### Required Variables

```bash
# Google OAuth Credentials
GOOGLE_OAUTH_CLIENT_ID=your-client-id-from-step-1.3
GOOGLE_OAUTH_CLIENT_SECRET=your-client-secret-from-step-1.3

# Enable OAuth 2.1 for multi-user support
MCP_ENABLE_OAUTH21=true

# Enable stateless mode for containers
WORKSPACE_MCP_STATELESS_MODE=true

# Server configuration
WORKSPACE_MCP_HOST=0.0.0.0
WORKSPACE_MCP_PORT=8000

# Tool tier (choose one: core, extended, complete)
TOOL_TIER=core
```

#### After First Deployment - Update External URL

After Coolify assigns your domain, update this variable:

```bash
WORKSPACE_EXTERNAL_URL=https://your-assigned-domain.coolify.io
```

Then redeploy the application.

### 2.5 Configure Domain

1. In Coolify, go to your application settings
2. Under **Domains**, add your domain or use the Coolify-provided subdomain
3. Enable **HTTPS** (Coolify handles Let's Encrypt automatically)
4. Save and wait for SSL certificate provisioning

### 2.6 Optional: Configure Persistent Storage

If you want to use disk-based OAuth storage instead of memory:

1. Add a volume in Coolify:
   - **Host Path:** `/path/on/nas/workspace-mcp-storage`
   - **Container Path:** `/app/store_creds`
2. Add environment variable:
   ```bash
   WORKSPACE_MCP_OAUTH_PROXY_STORAGE_BACKEND=disk
   GOOGLE_MCP_CREDENTIALS_DIR=/app/store_creds
   ```

## Step 3: Deploy

1. Click **Deploy** in Coolify
2. Wait for the build to complete
3. Check logs for any errors
4. Once running, note your application URL

## Step 4: Test the Deployment

### 4.1 Health Check

Visit: `https://your-domain.coolify.io/health`

You should see a health status response.

### 4.2 Test OAuth Flow

1. Use an MCP client (Claude Code, VS Code MCP, etc.)
2. Configure the client to connect to: `https://your-domain.coolify.io/mcp`
3. Try calling a tool - it should trigger the OAuth flow
4. Authenticate with your Google account
5. Verify the tool works

## Step 5: Connect MCP Clients

### Claude Code

```bash
claude mcp add --transport http workspace-mcp https://your-domain.coolify.io/mcp
```

### VS Code MCP Extension

Add to your VS Code settings:

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

## Troubleshooting

### OAuth Redirect Issues

If OAuth redirects fail:

1. Verify `WORKSPACE_EXTERNAL_URL` matches your actual domain
2. Check that HTTPS is enabled
3. Ensure the domain is accessible from the internet
4. Check Coolify logs for OAuth-related errors

### Container Won't Start

1. Check Coolify build logs
2. Verify all required environment variables are set
3. Ensure port 8000 is not already in use
4. Check NAS resources (CPU, memory, disk space)

### API Quota Errors

If you see quota errors:

1. Check Google Cloud Console quotas
2. Consider using `TOOL_TIER=core` to reduce API calls
3. Enable only the APIs you need

### Connection Timeouts

1. Check NAS firewall settings
2. Verify Coolify reverse proxy configuration
3. Ensure your domain DNS is correctly configured
4. Check if your ISP blocks incoming connections

## Advanced Configuration

### Using Redis/Valkey for Distributed Storage

If you have Redis/Valkey available:

```bash
WORKSPACE_MCP_OAUTH_PROXY_STORAGE_BACKEND=valkey
WORKSPACE_MCP_OAUTH_PROXY_VALKEY_HOST=your-redis-host
WORKSPACE_MCP_OAUTH_PROXY_VALKEY_PORT=6379
WORKSPACE_MCP_OAUTH_PROXY_VALKEY_PASSWORD=your-redis-password
```

### Granular Permissions

Instead of full access, use granular permissions:

```bash
PERMISSIONS=gmail:organize drive:readonly calendar:full
```

### Read-Only Mode

For a completely read-only deployment:

```bash
READ_ONLY=true
```

### Custom Tool Selection

Select only specific services:

```bash
TOOLS=gmail drive calendar
```

## Security Recommendations

1. **Use HTTPS**: Always enable HTTPS in Coolify
2. **Restrict Access**: Use Coolify's authentication or a reverse proxy with auth
3. **Rotate Secrets**: Periodically rotate your OAuth client secret
4. **Monitor Logs**: Regularly check Coolify logs for suspicious activity
5. **Backup Credentials**: If using disk storage, backup the `/app/store_creds` volume
6. **Network Isolation**: Consider using Coolify's network isolation features

## Maintenance

### Updating the Application

1. In Coolify, click **Redeploy**
2. Coolify will pull the latest code and rebuild
3. Check logs after deployment

### Monitoring

- Use Coolify's built-in monitoring
- Set up health check alerts
- Monitor Google API quota usage in Cloud Console

### Backup

If using persistent storage:
1. Backup the volume: `/path/on/nas/workspace-mcp-storage`
2. Backup your `.env` configuration
3. Keep a copy of your OAuth credentials

## Support

- **Repository Issues**: https://github.com/taylorwilsdon/google_workspace_mcp/issues
- **MCP Documentation**: https://modelcontextprotocol.io/
- **Coolify Documentation**: https://coolify.io/docs

## License

This project is licensed under the MIT License - see the LICENSE file for details.
