# v0.8.0

# Base node image
FROM node:20-alpine AS node

# Install jemalloc
RUN apk add --no-cache jemalloc
RUN apk add --no-cache python3 py3-pip uv

# Set environment variable to use jemalloc
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2

# Add `uv` for extended MCP support
COPY --from=ghcr.io/astral-sh/uv:0.6.13 /uv /uvx /bin/
RUN uv --version

RUN mkdir -p /app && chown node:node /app
WORKDIR /app

USER node

COPY --chown=node:node package.json package-lock.json ./
COPY --chown=node:node api/package.json ./api/package.json
COPY --chown=node:node client/package.json ./client/package.json
COPY --chown=node:node packages/data-provider/package.json ./packages/data-provider/package.json
COPY --chown=node:node packages/data-schemas/package.json ./packages/data-schemas/package.json
COPY --chown=node:node packages/api/package.json ./packages/api/package.json
COPY --chown=node:node librechat.yaml ./librechat.yaml

ENV CONFIG_PATH=/app/librechat.yaml
ENV SERVE_CLIENT=false

RUN \
    # Allow mounting of these files, which have no default
    touch .env ; \
    # Create directories for the volumes to inherit the correct permissions
    mkdir -p /app/client/public/images /app/api/logs /app/uploads ; \
    npm config set fetch-retry-maxtimeout 600000 ; \
    npm config set fetch-retries 5 ; \
    npm config set fetch-retry-mintimeout 15000 ; \
    # Relax peer dependency resolution to avoid ERESOLVE with smithy/langchain
    npm config set legacy-peer-deps true ; \
    npm install --no-audit --legacy-peer-deps

COPY --chown=node:node . .

RUN \
    # Build workspace packages first (required for runtime) - these MUST succeed
    npm run build:data-provider && \
    npm run build:data-schemas && \
    npm run build:api && \
    npm run build:client-package && \
    # React client build (may fail if frontend deps missing, that's OK for API-only)
    mkdir -p /app/client/dist; \
    (NODE_OPTIONS="--max-old-space-size=2048" npm run build:client || true); \
    # Ensure fallback index.html exists (required by server even if SERVE_CLIENT=false)
    if [ ! -f /app/client/dist/index.html ]; then \
      printf '<!doctype html><html><head><meta charset="utf-8"><title>LibreChat API</title></head><body><h1>LibreChat API</h1><p>Frontend is hosted separately.</p></body></html>' >/app/client/dist/index.html; \
    fi; \
    # Verify workspace packages' dist folders exist before pruning
    test -d /app/packages/data-schemas/dist && test -d /app/packages/data-provider/dist && test -d /app/packages/api/dist || (echo "ERROR: Workspace packages not built!" && exit 1); \
    # Prune dev dependencies (don't use --workspaces flag to preserve workspace packages)
    npm prune --omit=dev --ignore-scripts; \
    # Copy workspace packages to node_modules (more reliable than symlinks in Docker)
    mkdir -p /app/node_modules/@librechat; \
    # Copy package.json and dist folders for each workspace package
    echo "Copying workspace packages to node_modules..."; \
    mkdir -p /app/node_modules/@librechat/data-schemas; \
    cp /app/packages/data-schemas/package.json /app/node_modules/@librechat/data-schemas/ || (echo "ERROR: Failed to copy data-schemas package.json" && exit 1); \
    cp -r /app/packages/data-schemas/dist /app/node_modules/@librechat/data-schemas/ || (echo "ERROR: Failed to copy data-schemas dist" && exit 1); \
    mkdir -p /app/node_modules/@librechat/data-provider; \
    cp /app/packages/data-provider/package.json /app/node_modules/@librechat/data-provider/ || (echo "ERROR: Failed to copy data-provider package.json" && exit 1); \
    cp -r /app/packages/data-provider/dist /app/node_modules/@librechat/data-provider/ || (echo "ERROR: Failed to copy data-provider dist" && exit 1); \
    mkdir -p /app/node_modules/@librechat/api; \
    cp /app/packages/api/package.json /app/node_modules/@librechat/api/ || (echo "ERROR: Failed to copy api package.json" && exit 1); \
    cp -r /app/packages/api/dist /app/node_modules/@librechat/api/ || (echo "ERROR: Failed to copy api dist" && exit 1); \
    # Verify workspace packages are accessible via node_modules after copy
    echo "Verifying copied packages..."; \
    test -f /app/node_modules/@librechat/data-schemas/dist/index.cjs || (echo "ERROR: Cannot access data-schemas/dist/index.cjs!" && ls -la /app/node_modules/@librechat/ && ls -la /app/node_modules/@librechat/data-schemas/ && exit 1); \
    test -d /app/node_modules/@librechat/data-provider/dist || (echo "ERROR: data-provider dist not found!" && exit 1); \
    test -d /app/node_modules/@librechat/api/dist || (echo "ERROR: api dist not found!" && exit 1); \
    echo "Workspace packages copied successfully!"; \
    # Ensure @smithy packages are present post-prune (required by Bedrock via LangChain)
    npm install --production --no-save @smithy/signature-v4@^2.0.10 @smithy/protocol-http@^5.0.1 @smithy/eventstream-codec@^4.2.4 winston-daily-rotate-file@^5.0.0 || true; \
    # Also place @smithy/protocol-http at nested path used by @langchain/community as a fallback
    NESTED_DIR="/app/node_modules/@librechat/agents/node_modules/@langchain/community/node_modules/@smithy"; \
    mkdir -p "$NESTED_DIR"; \
    if [ -d "/app/node_modules/@smithy/protocol-http" ]; then \
      ln -sf /app/node_modules/@smithy/protocol-http "$NESTED_DIR/protocol-http" 2>/dev/null \
      || cp -r /app/node_modules/@smithy/protocol-http "$NESTED_DIR/" 2>/dev/null \
      || true; \
    fi; \
    # Final verification: ensure workspace packages still exist after all npm operations
    echo "Final verification of workspace packages..."; \
    test -f /app/node_modules/@librechat/data-schemas/dist/index.cjs || (echo "FATAL: data-schemas/dist/index.cjs missing after all operations!" && ls -la /app/node_modules/@librechat/ && exit 1); \
    test -d /app/node_modules/@librechat/data-provider/dist || (echo "FATAL: data-provider dist missing!" && exit 1); \
    test -d /app/node_modules/@librechat/api/dist || (echo "FATAL: api dist missing!" && exit 1); \
    echo "All workspace packages verified successfully!"; \
    npm cache clean --force

# Node API setup
EXPOSE 3080
ENV HOST=0.0.0.0
CMD ["npm", "run", "backend"]

# Optional: for client with nginx routing
# FROM nginx:stable-alpine AS nginx-client
# WORKDIR /usr/share/nginx/html
# COPY --from=node /app/client/dist /usr/share/nginx/html
# COPY client/nginx.conf /etc/nginx/conf.d/default.conf
# ENTRYPOINT ["nginx", "-g", "daemon off;"]
