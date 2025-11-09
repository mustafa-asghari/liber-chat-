# Secure Configuration Setup Guide

## Security Concerns

### Current Situation:
1. **Your config file** (`config/librechat.railway.yaml`) contains:
   - `apiKey: "dummy"` - Not sensitive (your API accepts any value)
   - `baseURL: "${CALORIESAI_BASE_URL}"` - Now uses environment variable (secure)
   - Model configurations - Not sensitive

2. **If you add real API keys later**, you need to keep them secret!

3. **`.gitignore`** already excludes:
   - `librechat.yaml` (root)
   - `librechat.yml` (root)
   - But `config/librechat.railway.yaml` is NOT ignored (it's in the repo)

## Secure Solutions for Railway

### Option 1: Use Railway's File Mounting (Recommended)

Railway allows you to upload files directly without committing them to git:

1. **Keep config file in `.gitignore`:**
   ```bash
   # Add to .gitignore
   config/librechat.railway.yaml
   ```

2. **Upload file to Railway:**
   - Go to Railway Dashboard → Your Service → Settings
   - Find "Files" or "Volumes" section
   - Upload `config/librechat.railway.yaml`
   - Mount it to `/app/librechat.yaml`

3. **Set environment variable:**
   ```
   CONFIG_PATH=/app/librechat.yaml
   ```

### Option 2: Use Environment Variables (Most Secure)

Instead of a config file, use environment variables for sensitive values:

1. **Create a minimal public config file** (safe to commit):
   ```yaml
   # config/librechat.public.yaml (safe to commit)
   version: 1.2.1
   endpoints:
     custom:
       - name: "caloriesai"
         apiKey: "${CALORIESAI_API_KEY}"  # Use env var
         baseURL: "${CALORIESAI_BASE_URL}"  # Use env var
         models:
           default:
             - "gpt-4o-mini"
             - "gpt-4o"
             - "gpt-4-turbo"
   ```

2. **Set secrets in Railway:**
   ```
   CALORIESAI_API_KEY=your-real-api-key-here
   CALORIESAI_BASE_URL=your-api-url-here
   CONFIG_PATH=/app/librechat.yaml
   ```

3. **LibreChat supports environment variable substitution** in YAML files!

### Option 3: Use Railway's Secrets/Environment Variables

Railway has a "Variables" section where you can store secrets:

1. **Go to Railway Dashboard → Your Service → Variables**
2. **Add sensitive values:**
   ```
   CALORIESAI_API_KEY=your-secret-key
   CALORIESAI_BASE_URL=your-api-url-here
   ```
3. **Reference them in your config file** using `${VAR_NAME}` syntax

### Option 4: Use Private GitHub Repo + Remote Config URL

1. **Keep config in a private GitHub repo**
2. **Set CONFIG_PATH to GitHub raw URL:**
   ```
   CONFIG_PATH=https://raw.githubusercontent.com/your-private-repo/main/config/librechat.railway.yaml
   ```
3. **Use GitHub token if needed** (Railway can authenticate)

## Recommended Secure Setup

### Step 1: Update .gitignore
Add to `.gitignore`:
```
# Config files with sensitive data
config/librechat.railway.yaml
config/librechat.*.yaml
!config/librechat.example.yaml
```

### Step 2: Create Example Config
Create `config/librechat.example.yaml` (safe to commit):
```yaml
version: 1.2.1
endpoints:
  custom:
    - name: "caloriesai"
      apiKey: "${CALORIESAI_API_KEY}"  # Set in Railway env vars
      baseURL: "${CALORIESAI_BASE_URL}"  # Set in Railway env vars
      models:
        default:
          - "gpt-4o-mini"
          - "gpt-4o"
          - "gpt-4-turbo"
```

### Step 3: Set Railway Environment Variables
In Railway Dashboard → Variables:
```
CALORIESAI_API_KEY=dummy  # Or your real key
CALORIESAI_BASE_URL=https://caloriesaiproject-production.up.railway.app/v1
CONFIG_PATH=/app/librechat.yaml
```

### Step 4: Upload Config File to Railway
- Upload `config/librechat.railway.yaml` directly to Railway (not via git)
- Mount it to `/app/librechat.yaml`
- Or use the example file and let env vars fill in the values

## Current Config Analysis

Your current config is **relatively safe** to commit because:
- ✅ `apiKey: "dummy"` - Not a real secret
- ✅ `baseURL` - Public URL (already accessible)
- ✅ Model names - Public information

**However**, if you want to:
- Add real API keys later
- Keep your API endpoint private
- Follow security best practices

Then use one of the secure options above.

## Quick Secure Setup for Railway

### Method 1: Railway File Upload (Easiest)

1. **Add to `.gitignore`:**
   ```bash
   echo "config/librechat.railway.yaml" >> .gitignore
   ```

2. **In Railway Dashboard:**
   - Go to your service → Settings → Files
   - Upload `config/librechat.railway.yaml`
   - Set mount path: `/app/librechat.yaml`

3. **Set environment variable:**
   ```
   CONFIG_PATH=/app/librechat.yaml
   ```

### Method 2: Environment Variables (Most Secure)

1. **Create template config** (commit to git):
   ```yaml
   # config/librechat.template.yaml
   version: 1.2.1
   endpoints:
     custom:
       - name: "caloriesai"
         apiKey: "${CALORIESAI_API_KEY}"
         baseURL: "${CALORIESAI_BASE_URL}"
         models:
           default:
             - "gpt-4o-mini"
             - "gpt-4o"
             - "gpt-4-turbo"
   ```

2. **In Railway, set environment variables:**
   ```
   CALORIESAI_API_KEY=dummy
   CALORIESAI_BASE_URL=your-api-url-here
   CONFIG_PATH=/app/librechat.yaml
   ```

3. **Upload the template file** to Railway (it will substitute env vars)

## Summary

- **Current config is safe** to commit (no real secrets)
- **For future security**, use Railway's file upload or environment variables
- **`.gitignore`** should exclude config files with secrets
- **Railway can mount files** without committing to git
- **Environment variables** are the most secure option

Choose the method that fits your security needs!

