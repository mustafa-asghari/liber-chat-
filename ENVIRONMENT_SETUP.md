# LibreChat Environment Setup Guide

## Overview

You're using LibreChat with:
1. ✅ **Your Custom Python API (CaloriesAI)** - Already configured on Railway
2. ⚠️ **MongoDB** - Required (needs to be set up)
3. ⚠️ **OpenAI API Key** - Optional (only if you want to use OpenAI models directly)

## Current Configuration

### ✅ Your Custom API (CaloriesAI)
- **Status:** Already configured
- **Location:** `config/librechat.railway.yaml`
- **URL:** Set via `CALORIESAI_BASE_URL` environment variable
- **Models:** gpt-4o-mini, gpt-4o, gpt-4-turbo
- **API Key:** "dummy" (your API accepts any value)

## Required: MongoDB Setup

### Option 1: MongoDB on Railway (Recommended)

1. **Add MongoDB Service on Railway:**
   - Go to your Railway project
   - Click "New" → "Database" → "Add MongoDB"
   - Railway will create a MongoDB instance

2. **Get MongoDB Connection String:**
   - Copy the `MONGO_URI` from Railway's MongoDB service
   - It will look like: `mongodb://mongo:27017/LibreChat` (internal) or 
   - External: `mongodb://username:password@host:port/LibreChat`

3. **Set Environment Variable:**
   - In your LibreChat Railway service, add:
     ```
     MONGO_URI=mongodb://[MONGODB_SERVICE_URL]/LibreChat
     ```
   - Replace `[MONGODB_SERVICE_URL]` with your actual MongoDB connection string

### Option 2: MongoDB in Docker Compose (Local/Development)

If using `deploy-compose.yml`, MongoDB is already configured:
```yaml
mongodb:
  container_name: chat-mongodb
  image: mongo
  restart: always
```

Connection string: `mongodb://mongodb:27017/LibreChat`

## Optional: OpenAI API Key

### When You Need It:
- If you want to use OpenAI models directly (not through your custom API)
- If you want to use OpenAI for conversation titles or other features
- If you want to offer both your custom API and OpenAI as options

### How to Set It Up:

1. **Get OpenAI API Key:**
   - Go to https://platform.openai.com/api-keys
   - Create a new API key
   - Copy the key

2. **Set Environment Variable:**
   - In your LibreChat Railway service, add:
     ```
     OPENAI_API_KEY=sk-your-openai-api-key-here
     ```

3. **Note:** Your custom API (CaloriesAI) will still work even without this key.

## Environment Variables Summary

### Required Variables:
```env
MONGO_URI=mongodb://[MONGODB_CONNECTION_STRING]/LibreChat
NODE_ENV=production
HOST=0.0.0.0
PORT=3080
CONFIG_PATH=/app/librechat.yaml
```

### Optional Variables:
```env
OPENAI_API_KEY=sk-your-key-here  # Only if using OpenAI directly
MEILI_HOST=http://meilisearch:7700  # Only if using Meilisearch
MEILI_MASTER_KEY=your-master-key  # Only if using Meilisearch
```

## Railway Deployment Checklist

### ✅ Already Configured:
- [x] Custom API (CaloriesAI) endpoint
- [x] Custom API models (gpt-4o-mini, gpt-4o, gpt-4-turbo)
- [x] Config file path

### ⚠️ Need to Configure:
- [ ] MongoDB service on Railway
- [ ] MONGO_URI environment variable
- [ ] (Optional) OPENAI_API_KEY if using OpenAI directly

## Quick Setup Steps for Railway

1. **Add MongoDB Service:**
   ```
   Railway Dashboard → New → Database → Add MongoDB
   ```

2. **Get MongoDB Connection String:**
   - Copy the `MONGO_URI` from MongoDB service
   - It should be something like: `mongodb://mongo:27017/LibreChat`

3. **Set Environment Variables in LibreChat Service:**
   ```
   MONGO_URI=mongodb://mongo:27017/LibreChat
   CONFIG_PATH=/app/librechat.yaml
   ```

4. **Deploy:**
   - Railway will automatically deploy when you push changes
   - Or manually trigger a deployment

## Testing Your Setup

1. **Check MongoDB Connection:**
   - LibreChat should start without MongoDB errors
   - Check logs: `railway logs [your-service-name]`

2. **Test Your Custom API:**
   - Open LibreChat UI
   - Select "CaloriesAI" from the endpoint dropdown
   - Try sending a message
   - It should use your Railway Python API

3. **Test OpenAI (if configured):**
   - Select "OpenAI" from the endpoint dropdown
   - Try sending a message
   - It should use OpenAI API directly

## Troubleshooting

### MongoDB Connection Issues:
- Check that MongoDB service is running on Railway
- Verify MONGO_URI is correct
- Check that services are in the same Railway project (for internal connections)

### Custom API Not Working:
- Verify your Python API is running on Railway
- Check the baseURL in `config/librechat.railway.yaml`
- Test the API directly: `curl ${CALORIESAI_BASE_URL}/chat/completions` (use your actual URL)

### OpenAI Not Working:
- Verify OPENAI_API_KEY is set correctly
- Check that you have credits in your OpenAI account
- Verify the API key has proper permissions

