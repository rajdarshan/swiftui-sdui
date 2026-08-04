#!/usr/bin/env node
/**
 * Validates SDUI payloads against COMPONENTS.md.
 * Enforces the rules CI can check without running the app:
 *   - manifest and payload files agree
 *   - schemaVersion is major.minor and >= every feature used (COMPONENTS.md §2.2)
 *   - manifest schemaVersion equals the highest in use
 *   - content version alignment
 *   - no null values anywhere
 *   - every item has a page-scoped unique id
 *   - itemWidth / icon / colour tokens are known
 *   - no fallback nested inside a fallback
 *   - item type is valid in its container
 * Exits non-zero on any error.
 */

import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const errors = [];
const warn = [];

/**
 * Feature -> schema version that introduced it. Derived from COMPONENTS.md.
 * MUST be updated in the same commit as any schema change (COMPONENTS.md §14).
 * A payload must declare a schemaVersion >= the highest Since among the
 * features it actually uses (COMPONENTS.md §2.2).
 */
const SINCE = {
  container: {
    rail: '1.0', grid: '1.0', carousel: '1.0', list: '1.0', single: '1.0', header: '1.0'
  },
  item: {
    tile: '1.0', modelCard: '1.0', iconTile: '1.0', carCard: '1.0',
    placeCard: '1.0', promoCard: '1.0', featureCard: '1.0', textBlock: '1.0'
  },
  action: {
    navigate: '1.0', openSheet: '1.0', toggle: '1.0', call: '1.0',
    openMaps: '1.0', openUrl: '1.0', search: '1.0', select: '1.0'
  },
  feature: {
    filter: '1.0', fallback: '1.0'
  }
};

const parseVer = (v) => {
  const m = /^(\d+)\.(\d+)$/.exec(String(v ?? ''));
  return m ? { major: +m[1], minor: +m[2] } : null;
};
const cmpVer = (a, b) => {
  const x = parseVer(a), y = parseVer(b);
  if (!x || !y) return NaN;
  return x.major - y.major || x.minor - y.minor;
};
const maxVer = (a, b) => (cmpVer(a, b) >= 0 ? a : b);

const CONTAINERS = new Set(Object.keys(SINCE.container));
const ITEMS = new Set(Object.keys(SINCE.item));

const MATRIX = {
  rail: new Set(['tile', 'modelCard', 'iconTile', 'carCard', 'placeCard']),
  grid: new Set(['tile', 'iconTile']),
  carousel: new Set(['promoCard']),
  list: new Set(['carCard', 'placeCard', 'featureCard']),
  single: new Set(['promoCard', 'featureCard', 'textBlock'])
};

const ITEM_WIDTHS = new Set(['sm', 'md', 'lg', 'xl', 'full']);

const ICONS = new Set([
  'grid', 'car', 'key', 'money', 'receipt', 'wrench', 'shield', 'phone',
  'directions', 'check', 'arrowRightCircle', 'heart', 'chevronDown', 'person'
]);

const COLOURS = new Set([
  'brand.primary', 'brand.primaryLight', 'brand.surfaceTranslucent',
  'surface.default', 'surface.muted', 'surface.brand', 'surface.chip',
  'tile.blue', 'tile.green', 'tile.cream', 'tile.creamBorder', 'tile.arch',
  'tile.dark', 'tile.orange',
  'text.primary', 'text.secondary', 'text.onDark', 'text.accent',
  'text.success', 'text.danger', 'badge.danger'
]);

const RADII = new Set(['none', 'sm', 'md', 'lg', 'pill']);

const ACTIONS = new Set(Object.keys(SINCE.action));

const err = (file, msg) => errors.push(`${file}: ${msg}`);

// ---------- manifest ----------

const manifestPath = join(ROOT, 'config.json');
if (!existsSync(manifestPath)) {
  console.error('config.json not found');
  process.exit(1);
}
const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
const pkg = JSON.parse(readFileSync(join(ROOT, 'package.json'), 'utf8'));

if (!parseVer(manifest.schemaVersion)) {
  err('config.json', `schemaVersion "${manifest.schemaVersion}" must be major.minor, e.g. "1.0"`);
}
if (manifest.releaseVersion !== pkg.version) {
  err('config.json', `releaseVersion ${manifest.releaseVersion} != package.json ${pkg.version} — run sync:version`);
}

// ---------- per payload ----------

function findNulls(node, path, file) {
  if (node === null) { err(file, `null value at ${path} — omit the key instead`); return; }
  if (Array.isArray(node)) { node.forEach((v, i) => findNulls(v, `${path}[${i}]`, file)); return; }
  if (typeof node === 'object') {
    for (const [k, v] of Object.entries(node)) findNulls(v, `${path}.${k}`, file);
  }
}

function checkStyle(style, file, path) {
  if (!style) return;
  for (const key of ['background', 'foreground', 'border']) {
    if (style[key] && !COLOURS.has(style[key])) {
      err(file, `unknown colour token "${style[key]}" at ${path}.${key}`);
    }
  }
  if (style.cornerRadius && !RADII.has(style.cornerRadius)) {
    err(file, `unknown radius token "${style.cornerRadius}" at ${path}.cornerRadius`);
  }
}

function checkActions(node, file, path, req) {
  if (!node || typeof node !== 'object') return;
  if (Array.isArray(node)) { node.forEach((v, i) => checkActions(v, file, `${path}[${i}]`, req)); return; }
  for (const [k, v] of Object.entries(node)) {
    if (k === 'action' && v && typeof v === 'object') {
      if (!v.type) err(file, `action missing type at ${path}.action`);
      else if (!ACTIONS.has(v.type)) err(file, `unknown action type "${v.type}" at ${path}.action`);
      else req.used = maxVer(req.used, SINCE.action[v.type]);
      if (!v.target) err(file, `action missing target at ${path}.action`);
      if (v.params) {
        for (const [pk, pv] of Object.entries(v.params)) {
          if (typeof pv !== 'string') err(file, `action param "${pk}" must be a string at ${path}.action`);
        }
      }
    }
    checkActions(v, file, `${path}.${k}`, req);
  }
}

function checkItem(item, container, file, path, ids, insideFallback, req) {
  if (!item || typeof item !== 'object') { err(file, `malformed item at ${path}`); return; }

  if (!item.id) err(file, `item missing id at ${path}`);
  else if (ids.has(item.id)) err(file, `duplicate item id "${item.id}" at ${path}`);
  else ids.add(item.id);

  if (!item.type) { err(file, `item missing type at ${path}`); return; }

  const known = ITEMS.has(item.type);
  if (known) req.used = maxVer(req.used, SINCE.item[item.type]);
  if (!known && !insideFallback && !item.fallback) {
    warn.push(`${file}: unknown item type "${item.type}" with no fallback at ${path} — will be skipped at runtime`);
  }
  if (known && MATRIX[container] && !MATRIX[container].has(item.type)) {
    err(file, `item type "${item.type}" not valid in container "${container}" at ${path}`);
  }

  if (item.fallback) {
    if (insideFallback) {
      err(file, `fallback nested inside a fallback at ${path} — one level only`);
    } else {
      req.used = maxVer(req.used, SINCE.feature.fallback);
      checkItem(item.fallback, container, file, `${path}.fallback`, ids, true, req);
    }
  }

  checkStyle(item.style, file, path);
  if (item.overlayBadge?.icon && !ICONS.has(item.overlayBadge.icon)) {
    err(file, `unknown icon token "${item.overlayBadge.icon}" at ${path}.overlayBadge`);
  }
  for (const b of item.trustBadges ?? []) {
    if (b.icon && !ICONS.has(b.icon)) err(file, `unknown icon token "${b.icon}" at ${path}.trustBadges`);
  }
}

let highestUsed = '1.0';

for (const entry of manifest.payloads) {
  const file = entry.path;
  const full = join(ROOT, file);

  if (!existsSync(full)) { err(file, 'listed in config.json but file not found'); continue; }

  const payload = JSON.parse(readFileSync(full, 'utf8'));

  if (payload.pageId !== entry.pageId) {
    err(file, `pageId "${payload.pageId}" != manifest "${entry.pageId}"`);
  }
  if (payload.schemaVersion !== entry.schemaVersion) {
    err(file, `schemaVersion "${payload.schemaVersion}" != manifest "${entry.schemaVersion}"`);
  }
  if (!parseVer(payload.schemaVersion)) {
    err(file, `schemaVersion "${payload.schemaVersion}" must be major.minor, e.g. "1.0"`);
  }
  if (cmpVer(payload.schemaVersion, manifest.schemaVersion) > 0) {
    err(file, `schemaVersion "${payload.schemaVersion}" exceeds manifest "${manifest.schemaVersion}"`);
  }

  const req = { used: '1.0' };
  if (payload.version !== entry.version) {
    err(file, `version "${payload.version}" != manifest "${entry.version}" — run sync:version`);
  }
  if (!file.endsWith(`${entry.pageId}.json`)) {
    err(file, `filename stem must match pageId "${entry.pageId}"`);
  }

  findNulls(payload, '$', file);
  checkActions(payload, file, '$', req);

  const ids = new Set();
  for (const [i, section] of (payload.sections ?? []).entries()) {
    const p = `$.sections[${i}]`;

    if (!section.id) err(file, `section missing id at ${p}`);
    else if (ids.has(section.id)) err(file, `duplicate id "${section.id}" at ${p}`);
    else ids.add(section.id);

    if (!section.type) { err(file, `section missing type at ${p}`); continue; }
    if (!CONTAINERS.has(section.type)) {
      warn.push(`${file}: unknown section type "${section.type}" at ${p} — will be skipped at runtime`);
      continue;
    }
    req.used = maxVer(req.used, SINCE.container[section.type]);

    checkStyle(section.style, file, p);

    if (section.type === 'header') {
      for (const t of section.tabs?.items ?? []) {
        if (t.icon && !ICONS.has(t.icon)) err(file, `unknown icon token "${t.icon}" on tab "${t.id}"`);
        if (/\p{Extended_Pictographic}/u.test(t.icon ?? '')) {
          err(file, `emoji literal in icon on tab "${t.id}" — tokens only`);
        }
      }
      continue;
    }

    if (section.itemWidth && !ITEM_WIDTHS.has(section.itemWidth)) {
      err(file, `unknown itemWidth "${section.itemWidth}" at ${p}`);
    }
    if (section.type === 'grid' && !(section.columns >= 2 && section.columns <= 4)) {
      err(file, `grid columns must be 2–4 at ${p}`);
    }

    if (section.filter) {
      req.used = maxVer(req.used, SINCE.feature.filter);
      const chips = section.filter.chips ?? [];
      if (chips.length < 2) err(file, `filter needs at least 2 chips at ${p}`);
      if (!chips.some(c => c.id === section.filter.defaultChipId)) {
        err(file, `defaultChipId "${section.filter.defaultChipId}" matches no chip at ${p}`);
      }
      chips.forEach((c, ci) =>
        (c.items ?? []).forEach((it, ii) =>
          checkItem(it, section.type, file, `${p}.filter.chips[${ci}].items[${ii}]`, ids, false, req)));
    } else if (section.type === 'single') {
      checkItem(section.item, 'single', file, `${p}.item`, ids, false, req);
    } else {
      if (!Array.isArray(section.items) || section.items.length === 0) {
        err(file, `container has no items at ${p}`);
      }
      (section.items ?? []).forEach((it, ii) =>
        checkItem(it, section.type, file, `${p}.items[${ii}]`, ids, false, req));
    }
  }

  // COMPONENTS.md §2.2 — declare the lowest version that can render this payload
  if (parseVer(payload.schemaVersion) && cmpVer(payload.schemaVersion, req.used) < 0) {
    err(file, `declares schemaVersion "${payload.schemaVersion}" but uses features from "${req.used}" — bump to "${req.used}"`);
  }
  if (parseVer(payload.schemaVersion) && cmpVer(payload.schemaVersion, req.used) > 0) {
    warn.push(`${file}: declares "${payload.schemaVersion}" but only needs "${req.used}" — safe, but over-declared`);
  }
  highestUsed = maxVer(highestUsed, req.used);
}

if (parseVer(manifest.schemaVersion) && cmpVer(manifest.schemaVersion, highestUsed) !== 0) {
  err('config.json', `schemaVersion "${manifest.schemaVersion}" should equal the highest in use "${highestUsed}"`);
}

// ---------- report ----------

for (const w of warn) console.warn(`  warn  ${w}`);

if (errors.length) {
  console.error(`\n✗ ${errors.length} validation error(s):\n`);
  for (const e of errors) console.error(`  ${e}`);
  process.exit(1);
}

console.log(`✓ ${manifest.payloads.length} payload(s) valid — schema ${manifest.schemaVersion}, release ${manifest.releaseVersion}`);
if (warn.length) console.log(`  (${warn.length} warning(s) — intentional for the fallback demo payload)`);
