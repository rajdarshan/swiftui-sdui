#!/usr/bin/env node
/**
 * Propagates sdui-config/package.json version into:
 *   - config.json  → releaseVersion, and every payloads[].version
 *   - each payload → version
 *
 * Run automatically by standard-version's postbump hook (.versionrc.json).
 * Payload `version` tracks content releases; `schemaVersion` tracks the
 * contract and is bumped by hand, never by this script.
 */

import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');

const version = JSON.parse(readFileSync(join(ROOT, 'package.json'), 'utf8')).version;
const manifestPath = join(ROOT, 'config.json');
const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));

manifest.releaseVersion = version;

let touched = 0;
for (const entry of manifest.payloads) {
  entry.version = version;

  const full = join(ROOT, entry.path);
  if (!existsSync(full)) {
    console.warn(`  warn  ${entry.path} listed in manifest but not found — skipped`);
    continue;
  }

  const payload = JSON.parse(readFileSync(full, 'utf8'));
  if (payload.version !== version) {
    payload.version = version;
    writeFileSync(full, JSON.stringify(payload, null, 2) + '\n');
    touched += 1;
  }
}

writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
console.log(`✓ synced version ${version} → config.json + ${touched} payload(s)`);
