# Railway Backend Deployment Guide

## Overview

This guide will help you deploy the LibreChat backend API on Railway. The backend serves both:
- ✅ API endpoints (`/api/*`)
- ✅ Frontend static files (built React app)
- ✅ All LibreChat packages

## Architecture

```
┌─────────────────────────────────────────┐
│     Railway Backend Service             │
│  ┌───────────────────────────────────┐  │
│  │  LibreChat API (Node.js)          │  │
│  │  - API endpoints                  │  │
│  │  - Serves frontend (client/dist)  │  │
│  │  - All packages built in          │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
              │
              ├──→ MongoDB (Railway Service)
              └──→ Your Python API (Railway Service)
```

## Step 1: Create Railway Project

1. **Go to Railway Dashboard:** https://railway.app
2. **Create New Project:**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your LibreChat repository
   - Railway will create a new project

## Step 2: Add MongoDB Service (Required)

### Option A: Railway's Managed MongoDB (Recommended)

1. **In Railway Dashboard:**
   - Click "New" → "Database" → "Add MongoDB"
   - Railway will create a MongoDB instance

2. **Get Connection String:**
   - Click on the MongoDB service
   - Go to "Variables" tab
   - Copy the `MONGO_URI` connection string
   - It will look like: `mongodb://mongo:27017/LibreChat` (internal) or external URL

### Option B: MongoDB Container

1. **Add New Service:**
   - Click "New" → "GitHub Repo" → "Empty Service"
   - Or use Railway's MongoDB template

2. **Configure:**
   - Use Docker image: `mongo:latest`
   - Port: `27017` (internal only)
   - Railway will assign internal hostname

## Step 3: Deploy LibreChat Backend

### Method 1: Using Dockerfile (Recommended)

1. **Add New Service:**
   - In Railway Dashboard, click "New" → "GitHub Repo"
   - Select your LibreChat repository
   - Railway will detect the `Dockerfile` or `Dockerfile.multi`

2. **Configure Service:**
   - **Service Name:** `librechat-api` (or any name you prefer)
   - **Source:** Your GitHub repo
   - Railway will automatically detect and use the Dockerfile

3. **Set Start Command:**
   - Go to Service → Settings → Deploy
   - Set Start Command: `node api/server/index.js`
   - Or Railway will use the CMD from Dockerfile

4. **Set Port:**
   - Railway automatically detects port from Dockerfile
   - Or set `PORT` environment variable to `3080`

### Method 2: Using Pre-built Image

1. **Add New Service:**
   - Click "New" → "Empty Service"

2. **Configure:**
   - Go to Settings → Deploy
   - Set Docker Image: `ghcr.io/danny-avila/librechat-dev-api:latest`
   - Set Start Command: `node api/server/index.js`

## Step 4: Configure Environment Variables

Go to your LibreChat service → **Variables** tab and add:

### Required Variables:

```env
# Server Configuration
NODE_ENV=production
HOST=0.0.0.0
PORT=3080

# MongoDB Connection
MONGO_URI=mongodb://mongo:27017/LibreChat
# OR if using external MongoDB:
# MONGO_URI=mongodb://username:password@host:port/LibreChat

# Config File
CONFIG_PATH=/app/librechat.yaml

# Your Custom API (CaloriesAI)
CALORIESAI_BASE_URL=https://caloriesaiproject-production.up.railway.app/v1
CALORIESAI_API_KEY=dummy
```

### Optional Variables:

```env
# Meilisearch (if using search)
MEILI_HOST=http://meilisearch:7700
MEILI_MASTER_KEY=your-master-key

# RAG API (if using RAG)
RAG_API_URL=http://rag-api:8000

# JWT Secrets (generate your own)
JWT_SECRET=your-jwt-secret-here
JWT_REFRESH_SECRET=your-refresh-secret-here

# Credentials Encryption
CREDS_KEY=your-creds-key-here
CREDS_IV=your-creds-iv-here
```

### Generate Secrets:

```bash
# Generate JWT_SECRET (32 bytes)
openssl rand -hex 32

# Generate JWT_REFRESH_SECRET (32 bytes)
openssl rand -hex 32

# Generate CREDS_KEY (32 bytes)
openssl rand -hex 32

# Generate CREDS_IV (16 bytes)
openssl rand -hex 16
```

## Step 5: Add Config File

### Option A: Upload Config File to Railway

1. **Prepare Config File:**
   - Use `config/librechat.railway.yaml` (already has env var placeholders)
   - Or create one based on `config/librechat.example.yaml`

2. **Upload to Railway:**
   - Go to Service → Settings → Files/Volumes
   - Upload `config/librechat.railway.yaml`
   - Set mount path: `/app/librechat.yaml`
   - Or Railway might auto-mount files in the repo

### Option B: Include in Repository

1. **Add Config File to Repo:**
   - Copy `config/librechat.example.yaml` to `librechat.yaml` in repo root
   - Update it with your settings (using env vars)
   - Commit to repository
   - Railway will include it in the build

2. **Set CONFIG_PATH:**
   - Set `CONFIG_PATH=/app/librechat.yaml` in Railway variables
   - Or use default path (Railway will find it)

### Option C: Use Remote Config URL

1. **Host Config File:**
   - Upload config to private GitHub repo or secure location
   - Get a direct URL to the raw file

2. **Set CONFIG_PATH:**
   ```
   CONFIG_PATH=https://raw.githubusercontent.com/your-repo/main/config/librechat.railway.yaml
   ```

## Step 6: Configure Build Settings

### If Using Dockerfile:

Railway will automatically:
- Detect `Dockerfile` or `Dockerfile.multi`
- Build the Docker image
- Run the container

### If Using Nixpacks (No Dockerfile):

1. **Go to Service → Settings → Build:**
   - Build Command: `npm run frontend` (builds all packages + frontend)
   - Start Command: `node api/server/index.js`

2. **Railway will:**
   - Install dependencies (`npm ci`)
   - Build all packages
   - Build frontend
   - Start the API server

## Step 7: Connect Services

### Link MongoDB to LibreChat:

1. **In Railway Dashboard:**
   - Go to LibreChat service
   - Click "Variables" tab
   - Click "Reference Variable"
   - Select MongoDB service → `MONGO_URI`
   - Railway will create the connection

2. **Or Set Manually:**
   - Copy `MONGO_URI` from MongoDB service
   - Paste into LibreChat service variables
   - Format: `mongodb://mongo:27017/LibreChat` (internal) or external URL

## Step 8: Deploy

1. **Trigger Deployment:**
   - Railway will automatically deploy on git push
   - Or manually trigger: Service → Deployments → "Deploy"

2. **Check Logs:**
   - Go to Service → Deployments → Latest → Logs
   - Look for: "Server listening on port 3080"
   - Check for any errors

3. **Get Public URL:**
   - Railway will assign a public URL
   - Go to Service → Settings → Networking
   - Generate a domain or use Railway's default domain

## Step 9: Verify Deployment

### Check Backend API:

```bash
# Test health endpoint
curl https://your-railway-app.railway.app/api/health

# Test API
curl https://your-railway-app.railway.app/api/endpoints
```

### Check Frontend:

1. **Open in Browser:**
   - Visit: `https://your-railway-app.railway.app`
   - You should see the LibreChat login page

2. **Test Custom Endpoint:**
   - Login to LibreChat
   - Select "CaloriesAI" from endpoint dropdown
   - Send a test message
   - It should use your Python API

## Step 10: Configure Custom Domain (Optional)

1. **In Railway Dashboard:**
   - Go to Service → Settings → Networking
   - Click "Generate Domain" or "Add Custom Domain"
   - Follow Railway's instructions to configure DNS

2. **Update Environment Variables:**
   - If needed, update `DOMAIN_CLIENT` and `DOMAIN_SERVER` variables
   - Set to your custom domain

## Troubleshooting

### Backend Won't Start:

1. **Check Logs:**
   - Railway Dashboard → Service → Deployments → Latest → Logs
   - Look for error messages

2. **Common Issues:**
   - Missing `MONGO_URI` → Set MongoDB connection string
   - Missing `CONFIG_PATH` → Set config file path
   - Port conflict → Set `PORT=3080`
   - Missing dependencies → Check build logs

### Config File Not Found:

1. **Verify CONFIG_PATH:**
   - Check `CONFIG_PATH` environment variable
   - Verify file exists at that path in container

2. **Check File Location:**
   - If using repo, file should be in root or `config/` directory
   - If using upload, verify mount path is correct

### MongoDB Connection Failed:

1. **Check MONGO_URI:**
   - Verify connection string is correct
   - Check if using internal or external URL
   - For Railway services, use internal hostname: `mongodb://mongo:27017/LibreChat`

2. **Verify Services are Linked:**
   - Check Railway service connections
   - Ensure MongoDB service is running
   - Check MongoDB service logs

### Custom Endpoint Not Working:

1. **Check Environment Variables:**
   - Verify `CALORIESAI_BASE_URL` is set
   - Verify `CALORIESAI_API_KEY` is set
   - Check config file has correct endpoint configuration

2. **Check Logs:**
   - Look for endpoint initialization errors
   - Verify config file is loaded correctly
   - Test API endpoint directly

## Quick Start Checklist

- [ ] Create Railway project
- [ ] Add MongoDB service
- [ ] Deploy LibreChat backend service
- [ ] Set environment variables (MONGO_URI, CONFIG_PATH, CALORIESAI_BASE_URL, etc.)
- [ ] Upload/config config file
- [ ] Link MongoDB to LibreChat service
- [ ] Deploy and verify
- [ ] Test API and frontend
- [ ] Configure custom domain (optional)

## Summary

- **Backend Deployment:** One Railway service for LibreChat API
- **MongoDB:** Separate Railway service (managed or container)
- **Config File:** Upload to Railway or include in repo
- **Environment Variables:** Set in Railway Dashboard
- **Frontend:** Served by backend (no separate service needed)
- **Custom API:** Configured via environment variables

Your backend is now deployed on Railway and serving both API and frontend! 🚀

