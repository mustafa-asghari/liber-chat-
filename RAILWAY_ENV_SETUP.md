# Railway Environment Variables Setup

## Required Environment Variables

To keep your API URL and keys secure, you need to set these environment variables in Railway:

### 1. API Configuration

```env
# Your custom API URL (keep this secret!)
CALORIESAI_BASE_URL=https://caloriesaiproject-production.up.railway.app/v1

# Your API key (use "dummy" if your API doesn't require authentication)
CALORIESAI_API_KEY=dummy
```

### 2. LibreChat Configuration

```env
# Path to your config file
CONFIG_PATH=/app/librechat.yaml

# MongoDB connection string
MONGO_URI=mongodb://[MONGODB_CONNECTION_STRING]/LibreChat

# Server configuration
NODE_ENV=production
HOST=0.0.0.0
PORT=3080
```

## How to Set Environment Variables in Railway

### Method 1: Railway Dashboard (Recommended)

1. **Go to Railway Dashboard:**
   - Open your LibreChat service
   - Click on "Variables" tab

2. **Add Environment Variables:**
   - Click "New Variable"
   - Add each variable:
     - `CALORIESAI_BASE_URL` = `https://caloriesaiproject-production.up.railway.app/v1`
     - `CALORIESAI_API_KEY` = `dummy`
     - `CONFIG_PATH` = `/app/librechat.yaml`
     - `MONGO_URI` = `mongodb://[your-mongodb-connection]/LibreChat`
     - etc.

3. **Save and Deploy:**
   - Railway will automatically redeploy with new environment variables
   - Your config file will use these values

### Method 2: Railway CLI

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Link your project
railway link

# Set variables
railway variables set CALORIESAI_BASE_URL=https://caloriesaiproject-production.up.railway.app/v1
railway variables set CALORIESAI_API_KEY=dummy
railway variables set CONFIG_PATH=/app/librechat.yaml
railway variables set MONGO_URI=mongodb://[your-mongodb-connection]/LibreChat
```

### Method 3: railway.toml or railway.json

Create a `railway.toml` file in your project root:

```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "node api/server/index.js"
healthcheckPath = "/api/health"
healthcheckTimeout = 100
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10

[variables]
CALORIESAI_BASE_URL = "https://caloriesaiproject-production.up.railway.app/v1"
CALORIESAI_API_KEY = "dummy"
CONFIG_PATH = "/app/librechat.yaml"
NODE_ENV = "production"
HOST = "0.0.0.0"
PORT = "3080"
```

**⚠️ WARNING:** Don't commit sensitive values to git! Use Railway's dashboard or CLI to set secrets.

## Security Best Practices

### ✅ DO:
- Set sensitive values in Railway Dashboard (they're encrypted)
- Use environment variables for all sensitive data
- Keep your config files in `.gitignore`
- Use Railway's secrets management for API keys and URLs

### ❌ DON'T:
- Commit actual API URLs to git
- Commit API keys to git
- Put sensitive values in `railway.toml` or `railway.json` if committing to git
- Share your `CALORIESAI_BASE_URL` publicly

## Verification

After setting environment variables:

1. **Check Railway Logs:**
   - Go to Railway Dashboard → Your Service → Deployments → Latest → Logs
   - Look for: "Custom config file loaded" (should not show errors)

2. **Test Your API:**
   - Open LibreChat UI
   - Select "CaloriesAI" endpoint
   - Send a test message
   - It should connect to your API using the environment variable

3. **Verify Environment Variables:**
   - Railway Dashboard → Your Service → Variables
   - Confirm all variables are set correctly

## Troubleshooting

### Error: "Missing API Key for caloriesai"
- **Cause:** `CALORIESAI_API_KEY` environment variable is not set
- **Fix:** Set `CALORIESAI_API_KEY` in Railway variables (can be "dummy")

### Error: "Missing Base URL for caloriesai"
- **Cause:** `CALORIESAI_BASE_URL` environment variable is not set
- **Fix:** Set `CALORIESAI_BASE_URL` in Railway variables with your API URL

### Config File Not Found
- **Cause:** `CONFIG_PATH` is incorrect or file doesn't exist
- **Fix:** 
  - Verify `CONFIG_PATH=/app/librechat.yaml` is set
  - Ensure config file is uploaded/mounted to Railway
  - Check file exists at the specified path

### Environment Variables Not Loading
- **Cause:** Service needs to be redeployed after adding variables
- **Fix:** 
  - Trigger a new deployment in Railway
  - Or restart the service
  - Variables are loaded on service startup

## Example: Complete Railway Setup

### Step 1: Set Environment Variables
```
CALORIESAI_BASE_URL=https://caloriesaiproject-production.up.railway.app/v1
CALORIESAI_API_KEY=dummy
CONFIG_PATH=/app/librechat.yaml
MONGO_URI=mongodb://mongo:27017/LibreChat
NODE_ENV=production
HOST=0.0.0.0
PORT=3080
```

### Step 2: Upload Config File
- Upload `config/librechat.railway.yaml` to Railway
- Mount it to `/app/librechat.yaml`

### Step 3: Deploy
- Railway will automatically deploy
- Check logs to verify config loads correctly
- Test the API endpoint

## Summary

- ✅ All sensitive values are now in environment variables
- ✅ Config files don't contain actual API URLs
- ✅ Set `CALORIESAI_BASE_URL` and `CALORIESAI_API_KEY` in Railway
- ✅ Your API URL is kept secret and secure
- ✅ Config files can be safely committed to git (no secrets)

Your API URL is now secure and only stored in Railway's encrypted environment variables!

