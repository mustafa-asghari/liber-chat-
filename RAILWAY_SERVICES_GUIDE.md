# Railway Services - What Goes Where

## 🎯 Simple Answer: ONE Service for All LibreChat Packages

You only need **ONE Railway service** for LibreChat. All packages are automatically built and bundled into this single service.

---

## 📦 Railway Service Breakdown

### Service 1: LibreChat API (Main Service) - **ONE SERVICE FOR ALL PACKAGES**

**Service Name:** `librechat-api` or `librechat`

**What Goes Here:**
```
✅ @librechat/backend (api/)
✅ @librechat/frontend (client/) - built and served
✅ @librechat/api (packages/api/)
✅ @librechat/data-schemas (packages/data-schemas/)
✅ librechat-data-provider (packages/data-provider/)
✅ @librechat/client (packages/client/)
```

**How It Works:**
- All packages are built during Docker build
- Everything is bundled into one container
- The API serves both backend API and frontend
- **You don't manually add packages - they're all included automatically**

**Railway Configuration:**
- **Service Type:** Web Service
- **Source:** Your GitHub repo
- **Dockerfile:** `Dockerfile.multi` (or use pre-built image)
- **Start Command:** `node api/server/index.js`
- **Port:** 3080

**Environment Variables:**
```env
NODE_ENV=production
HOST=0.0.0.0
PORT=3080
MONGO_URI=mongodb://[MONGODB_SERVICE_URL]/LibreChat
# ... all other env vars
```

---

### Service 2: MongoDB (Database) - **NO LIBRECHAT PACKAGES**

**Service Name:** `mongodb` or `librechat-db`

**What Goes Here:**
```
✅ MongoDB database only
❌ NO LibreChat packages
❌ NO @librechat packages
```

**Railway Configuration:**
- **Service Type:** Database Service (use Railway's MongoDB template)
- **OR:** Use Railway's managed MongoDB (recommended)
- **OR:** Deploy MongoDB container manually

**Connection:**
- LibreChat service connects to this via `MONGO_URI` environment variable

---

### Service 3: Meilisearch (Optional - Search) - **NO LIBRECHAT PACKAGES**

**Service Name:** `meilisearch` or `librechat-search`

**What Goes Here:**
```
✅ Meilisearch service only
❌ NO LibreChat packages
❌ NO @librechat packages
```

**Railway Configuration:**
- **Service Type:** Private Service
- **Image:** `getmeili/meilisearch:v1.12.3`
- **Port:** 7700 (internal only)

**Connection:**
- LibreChat service connects via `MEILI_HOST` environment variable

---

### Service 4: PostgreSQL (Optional - RAG) - **NO LIBRECHAT PACKAGES**

**Service Name:** `postgresql` or `librechat-vectordb`

**What Goes Here:**
```
✅ PostgreSQL database with pgvector extension
❌ NO LibreChat packages
❌ NO @librechat packages
```

**Railway Configuration:**
- **Service Type:** Database Service (use Railway's PostgreSQL template)
- **Image:** `pgvector/pgvector:0.8.0-pg15-trixie` (if deploying manually)

**Connection:**
- RAG API service connects to this (not directly to LibreChat)

---

### Service 5: RAG API (Optional - RAG) - **NO LIBRECHAT PACKAGES**

**Service Name:** `rag-api` or `librechat-rag`

**What Goes Here:**
```
✅ RAG API service only
❌ NO LibreChat packages
❌ NO @librechat packages
```

**Railway Configuration:**
- **Service Type:** Private Service
- **Image:** `ghcr.io/danny-avila/librechat-rag-api-dev-lite:latest`
- **Port:** 8000 (internal only)

**Connection:**
- LibreChat service connects via `RAG_API_URL` environment variable

---

## 🎯 Quick Reference Table

| Railway Service | LibreChat Packages? | What It Contains | Required? |
|----------------|---------------------|------------------|-----------|
| **LibreChat API** | ✅ **ALL PACKAGES** | All @librechat packages, backend, frontend | ✅ Required |
| **MongoDB** | ❌ No | MongoDB database only | ✅ Required |
| **Meilisearch** | ❌ No | Meilisearch service only | ❌ Optional |
| **PostgreSQL** | ❌ No | PostgreSQL database only | ❌ Optional |
| **RAG API** | ❌ No | RAG API service only | ❌ Optional |

---

## 📝 Step-by-Step Railway Setup

### Step 1: Create LibreChat Service (Main Service)

1. **Create New Service** in Railway
2. **Name:** `librechat-api`
3. **Source:** Connect your GitHub repo
4. **Railway will detect:** Dockerfile automatically
5. **Build:** Railway builds using `Dockerfile.multi`
6. **Result:** All packages are automatically included ✅

**You don't need to:**
- ❌ Manually add `@librechat/api`
- ❌ Manually add `@librechat/data-schemas`
- ❌ Manually add `librechat-data-provider`
- ❌ Manually add `@librechat/client`
- ❌ Manually add `@librechat/frontend`

**They're all included automatically in the build!**

---

### Step 2: Create MongoDB Service

1. **Create New Service** in Railway
2. **Template:** Use "MongoDB" template (recommended)
   - OR deploy MongoDB container manually
3. **Name:** `mongodb`
4. **No packages needed** - just the database

---

### Step 3: Configure Environment Variables

In your **LibreChat API service**, set:
```env
MONGO_URI=mongodb://[MONGODB_SERVICE_URL]/LibreChat
MEILI_HOST=http://[MEILISEARCH_SERVICE_URL]:7700  # If using
RAG_API_URL=http://[RAG_API_SERVICE_URL]:8000  # If using
# ... all other env vars
```

---

## 🔍 Common Confusion

### ❌ WRONG: Separate Services for Each Package

```
❌ Service 1: @librechat/api
❌ Service 2: @librechat/data-schemas
❌ Service 3: librechat-data-provider
❌ Service 4: @librechat/client
❌ Service 5: @librechat/frontend
❌ Service 6: @librechat/backend
```

**This is wrong!** These are not separate services - they're all packages that get built into one service.

---

### ✅ CORRECT: One Service with All Packages

```
✅ Service 1: LibreChat API (contains ALL packages)
   - @librechat/backend
   - @librechat/frontend
   - @librechat/api
   - @librechat/data-schemas
   - librechat-data-provider
   - @librechat/client

✅ Service 2: MongoDB (database only)
✅ Service 3: Meilisearch (optional, search only)
✅ Service 4: PostgreSQL (optional, database only)
✅ Service 5: RAG API (optional, RAG service only)
```

---

## 🎬 Visual Representation

```
┌─────────────────────────────────────┐
│   Railway Service: LibreChat API    │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  @librechat/backend (api/)    │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  @librechat/frontend (client) │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  @librechat/api               │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  @librechat/data-schemas      │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  librechat-data-provider      │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  @librechat/client            │  │
│  └───────────────────────────────┘  │
│                                     │
│  All built into ONE container!      │
└─────────────────────────────────────┘
         │
         ├──> Connects to MongoDB
         ├──> Connects to Meilisearch (optional)
         └──> Connects to RAG API (optional)

┌─────────────────────────────────────┐
│   Railway Service: MongoDB          │
│   (Database only, no packages)      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│   Railway Service: Meilisearch      │
│   (Search only, no packages)        │
└─────────────────────────────────────┘
```

---

## ✅ Summary

**ONE Railway service for LibreChat = All packages included automatically**

When you deploy LibreChat to Railway:
1. Create ONE service for LibreChat
2. Railway builds all packages automatically
3. All packages are bundled into one container
4. The service runs and serves both API and frontend

**You don't need to worry about individual packages - they're all handled automatically by the Docker build process!**

