# Coolify Deployment Checklist

Use this checklist to ensure a smooth deployment.

## Pre-Deployment

### Google Cloud Setup
- [ ] Created Google Cloud project
- [ ] Enabled Gmail API
- [ ] Enabled Drive API
- [ ] Enabled Calendar API
- [ ] Enabled Docs API
- [ ] Enabled Sheets API
- [ ] Enabled Slides API (if needed)
- [ ] Enabled Forms API (if needed)
- [ ] Enabled Tasks API (if needed)
- [ ] Enabled Chat API (if needed)
- [ ] Enabled People API (if needed)
- [ ] Enabled Apps Script API (if needed)
- [ ] Created OAuth 2.0 Desktop credentials
- [ ] Copied Client ID
- [ ] Copied Client Secret

### Coolify Preparation
- [ ] Coolify is installed and accessible
- [ ] Have admin access to Coolify dashboard
- [ ] Domain or subdomain ready (optional, Coolify can provide one)

## Deployment Steps

### Initial Setup
- [ ] Created new resource in Coolify
- [ ] Selected Git Repository source
- [ ] Entered repository URL: `https://github.com/taylorwilsdon/google_workspace_mcp.git`
- [ ] Selected `main` branch
- [ ] Set build method to Dockerfile
- [ ] Set container port to 8000

### Environment Variables
- [ ] Added `GOOGLE_OAUTH_CLIENT_ID`
- [ ] Added `GOOGLE_OAUTH_CLIENT_SECRET`
- [ ] Added `MCP_ENABLE_OAUTH21=true`
- [ ] Added `WORKSPACE_MCP_STATELESS_MODE=true`
- [ ] Added `WORKSPACE_MCP_HOST=0.0.0.0`
- [ ] Added `WORKSPACE_MCP_PORT=8000`
- [ ] Added `TOOL_TIER=core` (or your preferred tier)

### First Deployment
- [ ] Clicked Deploy
- [ ] Waited for build to complete
- [ ] Checked logs for errors
- [ ] Noted assigned URL

### Post-Deployment Configuration
- [ ] Added `WORKSPACE_EXTERNAL_URL` with assigned URL
- [ ] Redeployed application
- [ ] Verified health endpoint: `https://your-url/health`

### Domain Setup (if using custom domain)
- [ ] Added custom domain in Coolify
- [ ] Enabled HTTPS
- [ ] Waited for SSL certificate
- [ ] Updated `WORKSPACE_EXTERNAL_URL` to custom domain
- [ ] Redeployed

## Testing

### Basic Tests
- [ ] Health endpoint responds: `https://your-url/health`
- [ ] MCP endpoint accessible: `https://your-url/mcp`
- [ ] No errors in Coolify logs

### OAuth Flow Test
- [ ] Connected MCP client
- [ ] Triggered OAuth flow
- [ ] Successfully authenticated with Google
- [ ] Received access token
- [ ] Tool calls work correctly

### Service Tests
- [ ] Gmail tools work (if enabled)
- [ ] Drive tools work (if enabled)
- [ ] Calendar tools work (if enabled)
- [ ] Other services work as expected

## Security Checklist

- [ ] HTTPS is enabled
- [ ] OAuth credentials are secure (not in git)
- [ ] Environment variables are properly set in Coolify
- [ ] Health check is working
- [ ] Logs don't contain sensitive information
- [ ] Considered access restrictions (firewall, VPN, etc.)

## Optional Enhancements

### Storage Configuration
- [ ] Decided on storage backend (memory/disk/valkey)
- [ ] Configured persistent volume (if using disk)
- [ ] Set up Redis/Valkey (if using distributed storage)
- [ ] Tested storage persistence

### Advanced Features
- [ ] Configured custom search (if needed)
- [ ] Set up granular permissions (if needed)
- [ ] Configured allowed file directories (if needed)
- [ ] Set custom encryption key (recommended)

### Monitoring
- [ ] Set up Coolify monitoring alerts
- [ ] Configured log retention
- [ ] Set up backup for persistent data (if applicable)

## Troubleshooting

If something goes wrong, check:

- [ ] Coolify build logs
- [ ] Coolify runtime logs
- [ ] Google Cloud Console for API errors
- [ ] OAuth redirect URLs match
- [ ] All required environment variables are set
- [ ] Domain DNS is correctly configured
- [ ] Firewall allows incoming connections
- [ ] SSL certificate is valid

## Documentation

- [ ] Documented deployment for team
- [ ] Saved OAuth credentials securely
- [ ] Noted assigned URL/domain
- [ ] Documented any custom configuration
- [ ] Created backup of configuration

## Maintenance Plan

- [ ] Scheduled regular updates
- [ ] Set up monitoring alerts
- [ ] Planned backup strategy (if using persistent storage)
- [ ] Documented rollback procedure

---

## Quick Reference

**Repository**: `https://github.com/taylorwilsdon/google_workspace_mcp.git`
**Container Port**: `8000`
**Health Endpoint**: `/health`
**MCP Endpoint**: `/mcp`

**Required Environment Variables**:
```
GOOGLE_OAUTH_CLIENT_ID
GOOGLE_OAUTH_CLIENT_SECRET
MCP_ENABLE_OAUTH21=true
WORKSPACE_MCP_STATELESS_MODE=true
WORKSPACE_EXTERNAL_URL=https://your-domain
```

**Recommended Tool Tier**: `core` (start here, upgrade later)

---

**Need help?** See [COOLIFY_DEPLOYMENT.md](./COOLIFY_DEPLOYMENT.md) for detailed instructions.
