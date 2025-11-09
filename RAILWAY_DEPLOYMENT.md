# Railway Deployment Guide for LibreChat

## Understanding LibreChat Architecture

LibreChat is a **monorepo** with the following structure:

### Packages Structure:
- **`api/`** (`@librechat/backend`) - Backend Express server
- **`client/`** (`@librechat/frontend`) - React frontend app  
- **`packages/data-provider/`** - Shared data provider (used by both API and client)
- **`packages/data-schemas/`** (`@librechat/data-schemas`) - Data schemas (used by API)
- **`packages/api/`** (`@librechat/api`) - Shared API utilities (used by backend)
- **`packages/client/`** - Shared client utilities (used by frontend)

### How It Works:
- The **API server serves both**:
  1. API endpoints (Express routes at `/api/*`)
  2. Built frontend (static files from `client/dist`)
- All packages are **built during Docker build** and included in the final API container
- The client is built and served directly by the Express server

## Railway Deployment - What You Need

### ✅ ONE Service for LibreChat

You only need **ONE Railway service** for LibreChat itself. This single service includes:
- ✅ `@librechat/backend` (api/)
- ✅ `@librechat/frontend` (client/ - built and served)
- ✅ `@librechat/api` (packages/api/)
- ✅ `@librechat/data-schemas` (packages/data-schemas/)
- ✅ `librechat-data-provider` (packages/data-provider/)
- ✅ `@librechat/client` (packages/client/)

**All packages are built and bundled into the single API service.**

### ✅ Additional Services (Required/Optional)

1. **MongoDB** (Required)
   - Use Railway's managed MongoDB service OR
   - Deploy MongoDB as a separate service

2. **Meilisearch** (Optional - for search functionality)
   - Deploy as a separate service if you need search

3. **PostgreSQL + pgvector** (Optional - for RAG/vector database)
   - Deploy as a separate service if you need RAG functionality

4. **RAG API** (Optional - for RAG functionality)
   - Deploy as a separate service if you need RAG

## Railway Service Configuration

### Service 1: LibreChat API (Main Service)

**Configuration:**
- **Build Command:** (Railway will use Dockerfile automatically)
- **Start Command:** `node api/server/index.js`
- **Port:** 3080 (Railway will assign a public port)

**Environment Variables:**
```env
NODE_ENV=production
HOST=0.0.0.0
PORT=3080
MONGO_URI=mongodb://[MONGODB_SERVICE_URL]/LibreChat
MEILI_HOST=http://[MEILISEARCH_SERVICE_URL]:7700  # If using Meilisearch
RAG_API_URL=http://[RAG_SERVICE_URL]:8000  # If using RAG
CONFIG_PATH=/app/librechat.yaml
# Add all other required env vars from your .env file
```

**Dockerfile:**
Railway will automatically use your `Dockerfile.multi` or you can use the pre-built image:
```yaml
# In railway.json or use Dockerfile.multi
image: ghcr.io/danny-avila/librechat-dev-api:latest
```

**Config File:**
- Mount your `librechat.yaml` config file
- Or set `CONFIG_PATH` environment variable pointing to your config

### Service 2: MongoDB (Required)

**Option A: Use Railway's Managed MongoDB**
- Add MongoDB service from Railway's template
- Get connection string and set `MONGO_URI` in LibreChat service

**Option B: Deploy MongoDB Container**
- Use `mongo` Docker image
- Expose port 27017 (internal only)
- Set `MONGO_URI` in LibreChat service

### Service 3: Meilisearch (Optional)

**Configuration:**
- Use `getmeili/meilisearch:v1.12.3` image
- Expose port 7700 (internal only)
- Set `MEILI_MASTER_KEY` environment variable
- Set `MEILI_HOST` in LibreChat service

### Service 4: PostgreSQL + pgvector (Optional - for RAG)

**Configuration:**
- Use `pgvector/pgvector:0.8.0-pg15-trixie` image
- Set database credentials
- Used by RAG API service

### Service 5: RAG API (Optional - for RAG)

**Configuration:**
- Use `ghcr.io/danny-avila/librechat-rag-api-dev-lite:latest` image
- Connect to PostgreSQL service
- Set `RAG_API_URL` in LibreChat service

## Railway Configuration Files

### railway.json (Optional)

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile.multi"
  },
  "deploy": {
    "startCommand": "node api/server/index.js",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### Environment Variables in Railway

Set these in your LibreChat service:
- All variables from your `.env` file
- Database connection strings
- API keys
- Service URLs (for MongoDB, Meilisearch, etc.)

## Important Notes

1. **Single Service for LibreChat**: You don't need separate services for each package. The Docker build process bundles everything together.

2. **Client is Served by API**: The frontend is built and served directly by the Express server, so you don't need a separate frontend service.

3. **Package Dependencies**: All packages (`@librechat/api`, `@librechat/data-schemas`, `librechat-data-provider`, etc.) are built and included in the API service automatically.

4. **Config File**: Make sure your `librechat.yaml` is accessible. You can:
   - Include it in your repo and set `CONFIG_PATH`
   - Or mount it as a volume (if Railway supports it)

5. **Static Files**: The built client files are served from `/app/client/dist` in the container.

## Quick Start Checklist

- [ ] Create one Railway service for LibreChat API
- [ ] Set up MongoDB service (managed or container)
- [ ] Configure environment variables
- [ ] Set up config file (librechat.yaml)
- [ ] (Optional) Set up Meilisearch if needed
- [ ] (Optional) Set up PostgreSQL + RAG API if needed
- [ ] Deploy and test

## Summary

**You only need ONE service for LibreChat** that includes all packages. The other services (MongoDB, Meilisearch, etc.) are separate infrastructure services that LibreChat connects to.

