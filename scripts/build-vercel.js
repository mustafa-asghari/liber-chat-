#!/usr/bin/env node

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Get the project root directory
const rootDir = path.resolve(__dirname, '..');

// Change to project root
process.chdir(rootDir);

console.log('Building LibreChat for Vercel...');
console.log('Working directory:', process.cwd());

// Verify directories exist
const packages = [
  'packages/data-provider',
  'packages/data-schemas',
  'packages/api',
  'packages/client',
  'client'
];

// Check if directories exist
for (const pkg of packages) {
  const pkgPath = path.join(rootDir, pkg);
  if (!fs.existsSync(pkgPath)) {
    console.error(`Error: Directory not found: ${pkgPath}`);
    process.exit(1);
  }
}

// Build each package in order
const buildCommands = [
  { name: 'data-provider', path: 'packages/data-provider' },
  { name: 'data-schemas', path: 'packages/data-schemas' },
  { name: 'api', path: 'packages/api' },
  { name: 'client-package', path: 'packages/client' },
  { name: 'client', path: 'client' }
];

for (const cmd of buildCommands) {
  console.log(`\nBuilding ${cmd.name}...`);
  try {
    const pkgPath = path.join(rootDir, cmd.path);
    process.chdir(pkgPath);
    execSync('npm run build', { stdio: 'inherit' });
    process.chdir(rootDir);
    console.log(`✓ ${cmd.name} built successfully`);
  } catch (error) {
    console.error(`✗ Failed to build ${cmd.name}:`, error.message);
    process.exit(1);
  }
}

console.log('\n✓ All packages built successfully!');

