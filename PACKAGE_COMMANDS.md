# LibreChat Package Build and Start Commands

## @librechat/backend (api/)

**Build Command:**
- No build command (runs directly as Node.js)

**Start Command:**
```bash
cross-env NODE_ENV=production node api/server/index.js
```

**Start Command (from root):**
```bash
npm run backend
```

**Development Start:**
```bash
npm run backend:dev
```

---

## @librechat/frontend (client/)

**Build Command:**
```bash
cd client && cross-env NODE_ENV=production vite build && node ./scripts/post-build.cjs
```

**Build Command (from root):**
```bash
npm run build:client
```

**Start Command (Development):**
```bash
cd client && cross-env NODE_ENV=development vite
```

**Start Command (from root):**
```bash
npm run frontend:dev
```

**Note:** Frontend is built and served by the backend, not started separately in production.

---

## @librechat/api (packages/api/)

**Build Command:**
```bash
cd packages/api && npm run clean && rollup -c --bundleConfigAsCjs
```

**Build Command (from root):**
```bash
npm run build:api
```

**Start Command:**
- No start command (this is a library package, not a runnable service)

---

## librechat-data-provider (packages/data-provider/)

**Build Command:**
```bash
cd packages/data-provider && npm run clean && rollup -c --silent --bundleConfigAsCjs
```

**Build Command (from root):**
```bash
npm run build:data-provider
```

**Start Command:**
- No start command (this is a library package, not a runnable service)

---

## @librechat/data-schemas (packages/data-schemas/)

**Build Command:**
```bash
cd packages/data-schemas && npm run clean && rollup -c --silent --bundleConfigAsCjs
```

**Build Command (from root):**
```bash
npm run build:data-schemas
```

**Start Command:**
- No start command (this is a library package, not a runnable service)

---

## @librechat/client (packages/client/)

**Build Command:**
```bash
cd packages/client && npm run clean && rollup -c --bundleConfigAsCjs
```

**Build Command (from root):**
```bash
npm run build:client-package
```

**Start Command:**
- No start command (this is a library package, not a runnable service)

---

## Build Order (from root)

**Build all packages:**
```bash
npm run build:packages
```

This runs:
1. `npm run build:data-provider`
2. `npm run build:data-schemas`
3. `npm run build:api`
4. `npm run build:client-package`

**Build frontend (includes all packages):**
```bash
npm run frontend
```

This runs:
1. `npm run build:data-provider`
2. `npm run build:data-schemas`
3. `npm run build:api`
4. `npm run build:client-package`
5. `cd client && npm run build`

---

## Start Order (Production)

**Start backend (serves both API and built frontend):**
```bash
npm run backend
```

Or:
```bash
cross-env NODE_ENV=production node api/server/index.js
```

---

## Summary Table

| Package | Build Command | Start Command |
|---------|--------------|---------------|
| **@librechat/backend** | None (runs directly) | `node api/server/index.js` |
| **@librechat/frontend** | `cd client && vite build` | Built and served by backend |
| **@librechat/api** | `cd packages/api && rollup -c --bundleConfigAsCjs` | None (library) |
| **librechat-data-provider** | `cd packages/data-provider && rollup -c --silent --bundleConfigAsCjs` | None (library) |
| **@librechat/data-schemas** | `cd packages/data-schemas && rollup -c --silent --bundleConfigAsCjs` | None (library) |
| **@librechat/client** | `cd packages/client && rollup -c --bundleConfigAsCjs` | None (library) |

---

## Railway Build Command

**For Railway (single service with all packages):**
```bash
npm ci && npm run build:packages && npm run build:client
```

Or use the Dockerfile which handles this automatically.

---

## Railway Start Command

**For Railway:**
```bash
node api/server/index.js
```

