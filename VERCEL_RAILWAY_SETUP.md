# Vercel + Railway Setup Guide for LibreChat

## Architecture Overview

- **Vercel**: Deploys the frontend (React app) - Static files only
- **Railway**: Runs the backend API (Node.js server) - This is where your config file is used
- **Your Python API**: Already deployed on Railway

## Important: Where CONFIG_PATH is Used

### ❌ NOT on Vercel
Vercel only serves the frontend static files. It doesn't need `CONFIG_PATH` because:
- Vercel doesn't run the backend API
- The frontend is just HTML/CSS/JavaScript files
- Configuration is handled by the backend API

### ✅ YES on Railway (Backend API)
The backend API on Railway needs `CONFIG_PATH` because:
- The backend API reads `librechat.yaml` to configure endpoints
- The backend API handles requests and routes them to your custom API
- The backend API serves the frontend and handles API calls

## Setup Steps

### 1. Railway Backend API Service (Required)

This is where you deploy the LibreChat backend API.

#### Environment Variables on Railway:
```env
# Required
NODE_ENV=production
HOST=0.0.0.0
PORT=3080
MONGO_URI=mongodb://[MONGODB_CONNECTION_STRING]/LibreChat
CONFIG_PATH=/app/librechat.yaml

# Optional
MEILI_HOST=http://meilisearch:7700
MEILI_MASTER_KEY=your-master-key
```

#### Config File Setup:
You have two options:

**Option A: Mount Config File (Recommended)**
- In Railway, mount your `config/librechat.railway.yaml` file
- Set `CONFIG_PATH=/app/librechat.yaml`
- The file will be available at `/app/librechat.yaml` in the container

**Option B: Use Remote Config URL**
- Upload your config file to a publicly accessible URL (GitHub raw, etc.)
- Set `CONFIG_PATH=https://raw.githubusercontent.com/your-repo/main/config/librechat.railway.yaml`
- The backend will fetch it on startup

#### Your Current Config File:
Your `config/librechat.railway.yaml` already has your CaloriesAI API configured:
```yaml
endpoints:
  custom:
    - name: "caloriesai"
      apiKey: "dummy"
      baseURL: "${CALORIESAI_BASE_URL}"
      models:
        default:
          - "gpt-4o-mini"
          - "gpt-4o"
          - "gpt-4-turbo"
```

### 2. Vercel Frontend Service (Optional)

If you want to deploy the frontend on Vercel:

#### Vercel Environment Variables:
```env
# You need to set the backend API URL so the frontend knows where to connect
VITE_API_ENDPOINT=https://your-railway-api.railway.app
# OR if using a custom domain
VITE_API_ENDPOINT=https://api.yourdomain.com
```

#### Vercel Configuration:
- The `vercel.json` we created builds the frontend
- Output directory: `client/dist`
- No `CONFIG_PATH` needed on Vercel

### 3. Connecting Frontend to Backend

The frontend needs to know where the backend API is:

#### Option A: Backend Serves Frontend (Recommended)
- Deploy backend API on Railway
- Backend serves both API endpoints and frontend files
- No Vercel needed
- Frontend is automatically connected to backend

#### Option B: Frontend on Vercel, Backend on Railway
- Deploy frontend on Vercel
- Deploy backend API on Railway
- Set `VITE_API_ENDPOINT` environment variable on Vercel
- Frontend will make API calls to Railway backend

## Recommended Setup (Simplest)

### Single Service on Railway:

1. **Deploy LibreChat Backend on Railway:**
   - Use the Dockerfile or pre-built image
   - Set environment variables (MONGO_URI, CONFIG_PATH, etc.)
   - Mount or provide your `librechat.yaml` config file
   - Backend serves both API and frontend

2. **Config File Setup:**
   - Option 1: Mount `config/librechat.railway.yaml` as `/app/librechat.yaml`
   - Option 2: Set `CONFIG_PATH` to point to your config file location
   - Option 3: Use a remote URL for the config file

3. **Environment Variables:**
   ```
   CONFIG_PATH=/app/librechat.yaml
   MONGO_URI=mongodb://[your-mongodb-connection]/LibreChat
   NODE_ENV=production
   HOST=0.0.0.0
   PORT=3080
   ```

## Quick Setup Checklist

### Railway Backend API:
- [ ] Create Railway service for LibreChat API
- [ ] Set `CONFIG_PATH=/app/librechat.yaml`
- [ ] Mount or provide `config/librechat.railway.yaml` file
- [ ] Set `MONGO_URI` environment variable
- [ ] Set other required environment variables
- [ ] Deploy the service

### Vercel Frontend (Optional):
- [ ] Deploy frontend to Vercel
- [ ] Set `VITE_API_ENDPOINT` to your Railway backend URL
- [ ] No `CONFIG_PATH` needed on Vercel

## How It Works

1. **User visits your app** (either Railway or Vercel frontend)
2. **Frontend makes API calls** to Railway backend API
3. **Backend API reads `librechat.yaml`** (using CONFIG_PATH)
4. **Backend sees your custom endpoint** (CaloriesAI)
5. **Backend routes requests** to your API (set via `CALORIESAI_BASE_URL` environment variable)
6. **Your Python API processes** the request and returns response
7. **Backend forwards response** to frontend
8. **Frontend displays** the response to the user

## Troubleshooting

### Config File Not Found:
- Check that `CONFIG_PATH` points to the correct location
- Verify the file exists at that path in the container
- Check file permissions

### Custom Endpoint Not Appearing:
- Verify `librechat.yaml` has the custom endpoint configured
- Check that `apiKey` field is present (even if "dummy")
- Verify `baseURL` is correct
- Restart the backend API after config changes

### Frontend Can't Connect to Backend:
- Check `VITE_API_ENDPOINT` is set correctly (if using Vercel)
- Verify Railway backend is running and accessible
- Check CORS settings if needed

## Summary

- **CONFIG_PATH is for Railway (Backend API)**, not Vercel
- **Vercel only needs** the API endpoint URL (if using separate frontend)
- **Your CaloriesAI API** is already configured in `config/librechat.railway.yaml`
- **Set `CONFIG_PATH=/app/librechat.yaml`** on Railway backend service
- **Mount or provide the config file** to Railway backend

The configuration file tells the backend API about your custom endpoint, and the backend handles routing requests to your Python API on Railway.

