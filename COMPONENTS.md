# SDUI Component Reference

> **Schema version: 1.0**
>
> This document *is* the schema. The number above is what payloads declare in
> `schemaVersion`. Any change to the contract below — a new component, a new
> prop, a renamed token — requires a version bump per §2 and a row in §14.

Master registry for the swiftui-sdui home-screen system. Every payload must be
expressible with the types below. If a screen needs something not in here, that
is a **new client component** and must be counted as such in COVERAGE.md.

**Platform:** iOS 18.0+, SwiftUI

---

## 1. Conventions

| Marker | Meaning |
|---|---|
| **M** | Mandatory. Absent or malformed → fallback path (§10). |
| **O** | Optional. Absent → client default. |
| `token` | Named value resolved client-side. Never a raw hex, px, or font name. |
| **Since** | Schema version that introduced the feature. |

**Authoring rule:** omit absent keys. Never emit `null`. The decoder treats both
identically, but payloads must not contain nulls — CI lint enforces this.

**Division of responsibility**

| Server decides | Client decides |
|---|---|
| Which sections, in what order | Layout maths, spacing, safe areas |
| Which item type, and its data | Fonts, exact colours behind tokens |
| Intent of a tap (`type` + `target`) | What the destination actually is |
| Which chip is selected by default | Scroll physics, snapping, animation |
| Presence/absence of a node | Header collapse behaviour |

The server never describes a destination screen, a bottom sheet's contents, a
form, or a validation rule. Those are native. See §9.

---

## 2. Versioning

Two independent numbers. They answer different questions and never share a value.

| | `schemaVersion` | `version` |
|---|---|---|
| Question | Which **contract** does this payload speak? | Which **content revision** is this? |
| Format | `major.minor` string, e.g. `"1.0"` | semver string, e.g. `"1.4.2"` |
| Lives in | Every payload + manifest | Every payload + manifest |
| Owned by | This document | `sdui-config/package.json` |
| Bumped by | A human, editing this file | `standard-version` on release |
| Changes when | The contract changes | Copy, prices, ordering, images change |

### 2.1 Bumping the schema

**Minor** (`1.0` → `1.1`) — additive. An older client degrades correctly:
it skips what it doesn't know and renders the rest.

- New component type
- New optional prop on an existing component
- New token, icon, action type, container type
- New enum case on an optional field

**Major** (`1.x` → `2.0`) — breaking. An older client would render *wrongly*,
not merely partially.

- Removing or renaming a component, prop, or token
- Promoting an optional prop to mandatory
- Changing the meaning or type of an existing prop
- Removing an enum case

Major bumps are expensive and should be rare. Prefer adding a new optional prop
over changing an existing one, and a new component over redefining one.

### 2.2 Which version a payload declares

A payload declares the **lowest schema version that can render it** — that is,
the highest `Since` among every component, container, action, and token it
actually uses.

Consequences:

- A payload untouched by a schema change keeps its old number. The six stub
  pages will sit at `"1.0"` long after `home_all` has moved on.
- Adding one `1.2` component to a payload moves that payload to `"1.2"`.
- Payload version numbers are therefore *unequal across files*, by design. The
  manifest's top-level `schemaVersion` is the **highest in use**, not a value
  imposed on the payloads.

This is enforced by `scripts/validate-payloads.mjs`, which carries a
feature → `Since` table derived from this document.

### 2.3 What the client does with it

`schemaVersion` is **informational**. It does not gate rendering. A client that
supports `1.0` and receives a `1.3` payload still renders best-effort, node by
node, per §10 — that is what the fallback rules are for.

Its purposes are diagnostic and operational:

- Analytics: how many sessions are rendering payloads above their client's max
- Debugging: instantly tells you whether a missing section is a schema gap or a bug
- Server-side: lets a future server tailor payloads to a client's declared max

Because it does not gate, a schema bump can never blank a screen. The tradeoff
is that a major bump reaching an old client produces silently-wrong rendering
rather than a hard failure — which is exactly why major bumps are restricted to
the narrow list in §2.1.

### 2.4 Content version

`version` is the `sdui-config` package version, propagated into the manifest and
every payload by `scripts/sync-version.mjs` on `standard-version` postbump. It is
uniform across all payloads and tells you which release a device is running. It
carries no compatibility meaning.

---

## 3. Envelope

One file per top-level tab, indexed by a manifest.

| Prop | Type | Req | Since | Description |
|---|---|---|---|---|
| `schemaVersion` | string | **M** | 1.0 | `major.minor`. Lowest version that can render this payload (§2.2). |
| `version` | string | **M** | 1.0 | Content release. Semver. Machine-managed. |
| `pageId` | string | **M** | 1.0 | Stable id. Matches filename stem and tab `action.target`. |
| `sections` | Section[] | **M** | 1.0 | Ordered, rendered top to bottom. Empty array is valid. |

---

## 4. Value objects

### 4.1 Action

| Prop | Type | Req | Since | Description |
|---|---|---|---|---|
| `type` | enum | **M** | 1.0 | Unknown value → node renders, tap is a no-op. |
| `target` | string | **M** | 1.0 | Id of a destination the client knows. Never a constructed path. |
| `params` | map<string,string> | O | 1.0 | Flat only. No nesting, no arrays. |

| `type` | Meaning | `target` is | Since | Handled |
|---|---|---|---|:--:|
| `navigate` | Push a native screen | Route id | 1.0 | yes |
| `openSheet` | Present a native sheet | Sheet id | 1.0 | yes |
| `toggle` | Flip a boolean (wishlist) | Entity id | 1.0 | yes |
| `call` | Dial | Phone number | 1.0 | yes |
| `openMaps` | External maps intent | Place id (+ lat/lng in `params`) | 1.0 | yes |
| `openUrl` | External browser | Absolute URL | 1.0 | yes |
| `search` | Focus search surface | `search` | 1.0 | yes |
| `select` | Change selection state | Sibling section id | 1.0 | **no — reserved** |

`select` is documented but deliberately unhandled. It exercises the
unknown-action no-op path and is the seam for the standalone chip model (§11).

### 4.2 ImageRef

| Prop | Type | Req | Since | Description |
|---|---|---|---|---|
| `url` | string | **M** | 1.0 | Absolute. Load failure → slot collapses, card still renders. |
| `placeholder` | `token` | O | 1.0 | Fill while loading. Default `surface.muted`. |
| `aspect` | float | O | 1.0 | Width / height. Client reserves space pre-load to avoid layout shift. |

### 4.3 Badge

| Prop | Type | Req | Since |
|---|---|---|---|
| `text` | string | **M** | 1.0 |
| `icon` | `token` | O | 1.0 |
| `variant` | enum | O | 1.0 |

`variant`: `neutral` / `accent` / `success` / `warning` / `danger`. Default `neutral`.
Unknown icon token → icon omitted, text stays.

### 4.4 Button

| Prop | Type | Req | Since |
|---|---|---|---|
| `text` | string | **M** | 1.0 |
| `action` | Action | **M** | 1.0 |
| `variant` | enum | O | 1.0 |
| `leadingIcon` | `token` | O | 1.0 |

`variant`: `filled` / `outline` / `ghost`. Default `filled`.

### 4.5 Style

All optional; each a token name. Unknown token → client default.
`background` · `foreground` · `border` · `cornerRadius` — all Since 1.0.

### 4.6 Header

| Prop | Type | Req | Since |
|---|---|---|---|
| `title` | string | **M** | 1.0 |
| `badge` | Badge | O | 1.0 |
| `trailing` | Button | O | 1.0 |

---

## 5. Design tokens

Colour values sampled from the reference screenshots. Typography, spacing and
dimension scales live in `design_spec.md` §2 — that file owns *values*; this file
owns token *names*. All tokens below are Since 1.0.

### Colour

| Token | Hex | Used by |
|---|---|---|
| `brand.primary` | `#382BC3` | Header band |
| `brand.primaryLight` | `#5C4FF4` | Promo card, brand footer |
| `brand.surfaceTranslucent` | `#4B41C8` | Search fill, unselected chips |
| `surface.default` | `#FFFFFF` | Page background |
| `surface.muted` | `#F1F4F9` | Manage-vehicle tiles, modelCard bg |
| `surface.brand` | `#382BC3` | Section band behind Manage your vehicle |
| `surface.chip` | `#F9F9F9` | carCard spec chips |
| `tile.blue` | `#0F2A85` | Buy car tiles |
| `tile.green` | `#3C694C` | Sell your car tiles |
| `tile.cream` | `#FDF8F2` | Car check services tiles |
| `tile.creamBorder` | `#E8D9BE` | Border on cream tiles |
| `tile.arch` | `#F1F4FD` | Get loans arch background |
| `tile.dark` | `#1B2B22` | Partner promo banner |
| `tile.orange` | `#C2410C` | Carousel variant |
| `text.primary` | `#1A1A1A` | |
| `text.secondary` | `#6B7280` | |
| `text.onDark` | `#FFFFFF` | |
| `text.accent` | `#382BC3` | Links, "View all" |
| `text.success` | `#15803D` | "Open" status |
| `text.danger` | `#B31F1D` | "Closed" status |
| `badge.danger` | `#B31F1D` | Discount pill |

**Sampling caveat.** `brand.primary`, `brand.primaryLight`,
`brand.surfaceTranslucent`, `surface.muted`, `surface.chip`, `tile.blue`,
`tile.green`, `tile.cream`, `tile.arch` are pixel-sampled and exact.
`badge.danger` came from a small antialiased pill (+/-2 per channel).
`tile.creamBorder`, `tile.dark`, `text.primary`, `text.secondary`,
`text.success` are reasoned from context — treat as provisional.

### Text style
`display` · `sectionTitle` · `cardTitle` · `cardSubtitle` · `body` · `caption` ·
`eyebrow` · `price` · `priceNote` · `link`

### Corner radius
`none` · `sm` · `md` · `lg` · `pill`

### Item width

Peek ratio = how many items are visible across the viewport. The client owns the
arithmetic; the server only names a size.

| Token | Visible items | Used by |
|---|---|---|
| `sm` | 3.25 | `tile` rails, `iconTile` rails |
| `md` | 2.5 | `modelCard` |
| `lg` | 1.6 | `carCard` |
| `xl` | 1.3 | `placeCard` |
| `full` | 1.0 | Full width, no peek |

### Icon
`grid` · `car` · `key` · `money` · `receipt` · `wrench` · `shield` · `phone` ·
`directions` · `check` · `arrowRightCircle` · `heart` · `chevronDown` · `person`

Icons are **token-only**. Payloads never contain emoji literals. The client maps
each token to an SF Symbol — see `design_spec.md` §2.7.

---

## 6. Section containers

Common to every section:

| Prop | Type | Req | Since | Description |
|---|---|---|---|---|
| `id` | string | **M** | 1.0 | Unique within the page. |
| `type` | enum | **M** | 1.0 | Unknown → section skipped. |
| `header` | Header | O | 1.0 | |
| `style` | Style | O | 1.0 | `background` paints the whole section band. |
| `filter` | Filter | O | 1.0 | Valid on `rail`, `grid`, `list`. |

| Type | Since | Props | Covers |
|---|---|---|---|
| `rail` | 1.0 | `items[]` **M\***, `itemWidth` O (default `md`), `snap` O | Buy car, Sell your car, Get loans, Used cars, Showrooms, Trending |
| `grid` | 1.0 | `items[]` **M\***, `columns` **M** (2–4) | Car check services, Manage your vehicle |
| `carousel` | 1.0 | `items[]` **M\***, `loop` O, `peek` O, `autoScrollMs` O | Value-prop carousel |
| `list` | 1.0 | `items[]` **M\*** | (unused on this screen) |
| `single` | 1.0 | `item` **M** | Partner promo, Find-your-match, Safer-roads, footer |
| `header` | 1.0 | see §9 | App header |

\* Mandatory unless `filter` is present, which supplies items instead.

`loop: true` with exactly 2 items → client duplicates the second to fill both
edges. Client behaviour, not a server flag.

---

## 7. Filter (section-embedded chips)

| Prop | Type | Req | Since | Description |
|---|---|---|---|---|
| `chips` | Chip[] | **M** | 1.0 | Minimum 2. |
| `defaultChipId` | string | **M** | 1.0 | No match → falls back to index 0. |

**Chip:** `id` **M**, `label` **M**, `items` Item[] **M** — all Since 1.0.

Selection state is local to the section. All chips' items ship upfront —
acceptable at 2 chips x ~3 cards; revisit at larger fan-out.

---

## 8. Item types

Eight types. **Every item carries `id` (M) and may carry `fallback` (O).**

| Prop | Type | Req | Since | Description |
|---|---|---|---|---|
| `id` | string | **M** | 1.0 | Unique **page-scoped**. Required for SwiftUI structural identity. |
| `type` | string | **M** | 1.0 | Registry key. |
| `fallback` | Item | O | 1.0 | Rendered if `type` is unknown. One level only — a fallback must not itself declare a `fallback`. |

| Type | Since | Props |
|---|---|---|
| `tile` | 1.0 | `title` **M** · `image` O · `style` O · `action` **M** |
| `modelCard` | 1.0 | `title` **M** · `image` **M** · `subtitle` O · `watermark` O · `style` O · `action` **M** |
| `iconTile` | 1.0 | `label` **M** · `image` **M** · `imageShape` O (`circle`/`arch`/`square`) · `action` **M** |
| `carCard` | 1.0 | `image` **M** · `title` **M** · `price` **M** · `action` **M** · `overlayBadge` O · `favorite` O `{selected, action}` · `subtitle` O · `specs` O string[] · `priceSuffix` O · `priceNote` O `{text, action?}` · `trustBadges` O Badge[] |
| `placeCard` | 1.0 | `images` **M** ImageRef[] (min 1) · `title` **M** · `overlayBadge` O · `subtitle` O · `linkRow` O `{text, trailingIcon?, action}` · `status` O `{text, detail?, variant: success/danger/neutral}` · `buttons` O Button[] (0–2) |
| `promoCard` | 1.0 | `title` **M** · `image` O · `eyebrow` O · `subtitle` O · `logos` O ImageRef[] · `button` O · `style` O |
| `featureCard` | 1.0 | `title` **M** · `body` O · `image` O · `imagePosition` O (`leading`/`top`) · `badge` O · `footer` O `{text, trailingIcon?, action}` |
| `textBlock` | 1.0 | `title` **M** · `subtitle` O · `style` O |

Screen mapping: `tile` → Buy car, Sell your car, Car check services, Manage your
vehicle · `modelCard` → Trending new cars · `iconTile` → Get loans · `carCard` →
Used cars you'll love · `placeCard` → showrooms · `promoCard` → partner promo,
value-prop carousel, safer-roads · `featureCard` → find your match · `textBlock`
→ brand footer and the six stub pages.

---

## 9. Header section

`type: "header"`. First section if present. Pinned; collapse is client-owned.

| Prop | Type | Req | Since | Description |
|---|---|---|---|---|
| `search` | object | **M** | 1.0 | `{ placeholders: string[], rotateMs?, action }` |
| `tabs` | object | **M** | 1.0 | `{ items: [{ id, label, icon, action }], selectedId }` — 7 tabs |
| `location` | object | O | 1.0 | `{ text, action }` |
| `avatar` | object | O | 1.0 | `{ image, action }` |

**Deliberately not in the registry:** bottom sheets, form fields, checkboxes,
text inputs, rich/legal text. Login, add-vehicle, city-picker and price-breakup
are native. The server names them via `openSheet` and nothing more.

---

## 10. Fallback rules

Every one must be demonstrable in the screen recording.

| Situation | Behaviour |
|---|---|
| Unknown section `type` | Section skipped. Siblings render. |
| Unknown item `type`, `fallback` present and known | Render the fallback. |
| Unknown item `type`, no usable `fallback` | Item skipped. Container renders remaining items. |
| Known type, missing mandatory prop | Same as unknown type: try `fallback`, else skip. |
| `fallback` itself unknown, or nested twice | Ignored. Item skipped. |
| Unknown `action.type` (incl. `select`) | Node renders; tap logs and does nothing. |
| Unknown token | Client default substituted. |
| `defaultChipId` matches no chip | Index 0. |
| Duplicate item `id` within a page | Decoder logs; last occurrence wins. CI lint should catch it first. |
| Image load failure | Slot collapses; text still renders. |
| `schemaVersion` above the client's max | Renders best-effort per every rule above. Never gates. |

All degradation is **node-level**. A bad payload must never blank a page.

---

## 11. Extension notes

Prefer adding a prop to an existing item over a new item type, and a new item
over a new container. Five containers cover essentially every list-shaped layout.

Guard against prop creep: if an item accumulates optional props most call sites
ignore, split it. `modelCard` is separate from `tile` for exactly this reason.

**Planned — standalone chip groups (minor bump).** Add a `chipGroup` section
emitting `select` against a sibling `id`, plus `datasets` + `activeDatasetId` on
containers. Keep the §7 `filter` handler alongside. An old client skips the
unknown `chipGroup` and renders the container at its default dataset — degraded
but correct. Additive, so `1.0` → `1.1`. This is the worked example for the
README's versioning section.

---

## 12. Compatibility matrix

| Item | `rail` | `grid` | `carousel` | `list` | `single` |
|---|:--:|:--:|:--:|:--:|:--:|
| `tile` | yes | yes | | | |
| `modelCard` | yes | | | | |
| `iconTile` | yes | yes | | | |
| `carCard` | yes | | | yes | |
| `placeCard` | yes | | | yes | |
| `promoCard` | | | yes | | yes |
| `featureCard` | | | | yes | yes |
| `textBlock` | | | | | yes |

A `fallback` node must itself be valid in the parent container.

---

## 13. File layout

```
sdui-config/
├── config.json              # manifest: schema + content version, payload index
├── payloads/
│   ├── home_all.json
│   ├── home_buy_used_car.json
│   ├── home_sell_car.json
│   ├── home_loans.json
│   ├── home_challan.json
│   ├── home_car_check.json
│   ├── home_insurance.json
│   └── home_all_fallback_demo.json
├── scripts/
│   ├── validate-payloads.mjs
│   └── sync-version.mjs
├── .versionrc.json
├── CHANGELOG.md
└── package.json
```

The six non-`all` payloads are stubs: one `single` section containing a
`textBlock` with the tab name. `pageId` matches the filename stem; tab
`action.target` values match `pageId`.

### Manifest

| Prop | Description |
|---|---|
| `manifestVersion` | Shape of this file. Independent of the schema. |
| `schemaVersion` | **Highest** schema version in use across payloads. Derived, not imposed. |
| `releaseVersion` | Content version, mirrors `package.json`. |
| `payloads[]` | `pageId`, `path`, `version`, `schemaVersion`, `minAppVersion` |

Per-entry `schemaVersion` is what that payload declares and may differ between
entries — see §2.2.

---

## 14. Schema history

| Version | Date | Change |
|---|---|---|
| 1.0 | initial | First contract. 5 containers + header, 8 item types, 8 action types, 21 colour tokens, nested one-level fallback, page-scoped item ids, `sm`/`md`/`lg`/`xl`/`full` item widths. |

Every future row must state whether the change is minor (additive) or major
(breaking) per §2.1, and the validator's feature table must be updated in the
same commit.
