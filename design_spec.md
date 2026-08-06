# design_spec.md

**Source of truth for swiftui-sdui.** Implementation must not
deviate from this file. If something is not specified here, stop and ask — do
not invent, infer, or fill gaps from general knowledge.

Companion documents:
- `COMPONENTS.md` — the JSON schema contract (token *names*, node shapes, fallback rules, versioning)
- `CLAUDE.md` — workflow, build commands, commit rules, stage gates

**Schema version 1.0.** Payload compatibility is governed by `COMPONENTS.md` §2.
This file changes design *values*; changing them does not bump the schema, since
tokens are resolved client-side and their values are never in the payload.

| | |
|---|---|
| Platform | iOS 18.0+ |
| Xcode | 26.5 |
| UI | SwiftUI |
| Concurrency | async/await, `@Observable` |
| Target | Single app target, `iOS/SwiftUISDUI.xcodeproj` |
| Dark mode | **Out of scope.** Light only. |
| Dynamic Type | **Out of scope.** Fixed point sizes. |
| Localisation | **Out of scope.** en-IN strings, server-formatted currency. |
| Schema | 1.0 (see `COMPONENTS.md` §2) |

---

## 1. Reference screenshots

Screenshots of the reference app live in `reference/` at the repo root. That
folder is **gitignored and local-only** — it is never committed, and nothing in
it may be copied into the repo, the README, or any committed asset catalogue.
It exists solely for visual comparison during development.

Scroll order: `IMG_4361` → `IMG_4365` → `IMG_4364` → `IMG_4363` → `IMG_4362`

Plus `IMG_4366` (showroom card unclipped), `IMG_4367` (bottom sheet),
`IMG_4368` (header tabs scrolled right).

Captures are 1170x2532 @3x = **390x844pt logical**. All pt values below derive
from that reference width.

If `reference/` is absent, the values in §2 are authoritative on their own —
do not block on the screenshots and do not ask for them to be restored.

---

## 2. Design system

### 2.1 Colour

Values pixel-sampled from the reference screenshots. Define as a `Palette` enum
of `Color` constants. Token names are fixed by `COMPONENTS.md` §4.

| Token | Hex | Confidence |
|---|---|---|
| `brand.primary` | `#382BC3` | sampled |
| `brand.primaryLight` | `#5C4FF4` | sampled |
| `brand.surfaceTranslucent` | `#4B41C8` | sampled |
| `surface.default` | `#FFFFFF` | sampled |
| `surface.muted` | `#F1F4F9` | sampled |
| `surface.brand` | `#382BC3` | sampled |
| `surface.chip` | `#F9F9F9` | sampled |
| `tile.blue` | `#0F2A85` | sampled |
| `tile.green` | `#3C694C` | sampled |
| `tile.cream` | `#FDF8F2` | sampled |
| `tile.arch` | `#F1F4FD` | sampled |
| `tile.creamBorder` | `#E8D9BE` | provisional |
| `tile.dark` | `#1B2B22` | provisional |
| `tile.orange` | `#C2410C` | provisional |
| `text.primary` | `#1A1A1A` | provisional |
| `text.secondary` | `#6B7280` | provisional |
| `text.onDark` | `#FFFFFF` | sampled |
| `text.accent` | `#382BC3` | sampled |
| `text.success` | `#15803D` | provisional |
| `text.danger` | `#B31F1D` | provisional |
| `badge.danger` | `#B31F1D` | sampled, antialiased (+/-2) |

### 2.2 Typography

System font (SF Pro) at **fixed sizes**. No `.dynamicTypeSize`, no text styles
that scale. Use `.font(.system(size:weight:))`.

| Token | Size | Weight | Used by |
|---|---|---|---|
| `display` | 34 | bold | Brand footer headline |
| `sectionTitle` | 22 | bold | "Buy car", "Get loans" |
| `cardTitle` | 17 | semibold | Card and tile titles |
| `cardSubtitle` | 15 | regular | "Kia", "W6 1.2 PETROL" |
| `body` | 15 | regular | featureCard body |
| `caption` | 13 | regular | Spec chips, status detail |
| `eyebrow` | 11 | bold | Promo eyebrow — uppercase, +0.5 tracking |
| `price` | 17 | bold | "₹6.60 lakh" |
| `priceNote` | 12 | regular | "+other charges" — dotted underline when tappable |
| `link` | 15 | semibold | "View all", "Get directions" |

Line limits: `cardTitle` 2, `cardSubtitle` 1, `body` 3, tile `title` 2.
Truncation `.tail`.

### 2.3 Spacing

4pt base scale: **4, 8, 12, 16, 20, 24, 32, 40**

| Purpose | Value |
|---|---|
| Page horizontal margin | 16 |
| Section vertical gap | 24 |
| Section header → content | 12 |
| Rail inter-item gap | 12 |
| Grid gutter (h and v) | 12 |
| Card internal padding | 12 |
| Tile internal padding | 12 |

### 2.4 Corner radius

`none` 0 · `sm` 8 · `md` 12 · `lg` 16 · `pill` 999

### 2.5 Dimensions

| Element | Value |
|---|---|
| Header expanded height | 280 |
| Header collapsed height | 104 |
| Search field height | 44 |
| Tab chip circle | 56 |
| Tab strip height (collapsed) | 44 |
| `tile` height | 84 |
| `iconTile` image | 92 square |
| `carCard` image aspect | 1.5 |
| `placeCard` image aspect | 1.5 |
| `modelCard` image aspect | 1.5 |
| `promoCard` aspect | 1.8 |
| Button height | 44 |
| Spec chip height | 26 |

Values are derived by measurement from the reference captures and rounded to the
4pt scale. They are approximations of the original design, not exact recreations.

### 2.6 Item width resolution

```
itemWidth(token) = (availableWidth - 2*16 - gap*floor(ratio)) / ratio
```

`ratio`: `sm` 3.25 · `md` 2.5 · `lg` 1.6 · `xl` 1.3 · `full` 1.0

`availableWidth` is measured **once at the page container** and injected via
`@Environment`. Never place a `GeometryReader` inside a rail or a lazy row.

### 2.7 Icon tokens

Map each token to an SF Symbol. No emoji literals in payloads.

| Token | SF Symbol |
|---|---|
| `grid` | `square.grid.2x2.fill` |
| `car` | `car.fill` |
| `key` | `key.fill` |
| `money` | `indianrupeesign.circle.fill` |
| `receipt` | `doc.text.fill` |
| `wrench` | `wrench.and.screwdriver.fill` |
| `shield` | `checkmark.shield.fill` |
| `phone` | `phone.fill` |
| `directions` | `arrow.triangle.turn.up.right.diamond.fill` |
| `check` | `checkmark.circle` |
| `arrowRightCircle` | `arrow.right.circle.fill` |
| `heart` | `heart` / `heart.fill` when selected |
| `chevronDown` | `chevron.down` |
| `person` | `person.crop.circle.fill` |

---

## 3. Architecture

### 3.1 Layering

```
PayloadSource (protocol, async)
  ├── BundlePayloadSource        stages 1–5
  └── SupabasePayloadSource      stage 6
            │
      PayloadDecoder ──uses──> ComponentRegistry (decode closures)
            │
      PageStore (@Observable, @MainActor)   one per pageId
            │   holds [SectionNode], filter selections, load state
            ├──> SDUIPageView ──> ComponentRegistry (view closures)
            │           │
            │      ActionHandler ──> Router / SheetPresenter / DebugActionScreen
            │
      ScreenPerformanceTracker (actor)   instrumented from both variants
```

### 3.2 Rules

1. **Nodes are value types.** Structs. No node-level view models, no
   `ObservableObject` per node. 45 observable objects per page is the single
   biggest perf risk and is prohibited.
2. **One `PageStore` per `pageId`**, `@Observable`, `@MainActor`.
3. **Registry is a dictionary keyed by the `type` string**, holding a decode
   closure and a view closure per type. Not a Swift `enum`. Rationale: adding a
   component must be one new file plus one registration line, because the
   assignment is timed on exactly that.
4. **Actions are data.** Nodes carry `Action` values, never closures.
   `ActionHandler` is injected via `@Environment`.
5. **Leaf views are shared** between the static and SDUI screens. A leaf view
   takes plain Swift values, never a JSON node and never the registry.
6. **Every node has a stable `id`**; every `ForEach` uses it explicitly.
7. **`schemaVersion` never gates rendering.** The client reads it, logs it with
   performance samples, and renders best-effort regardless. Compatibility is
   handled node-by-node by the fallback rules, not by a version check.

### 3.3 Decoding and fallback

Heterogeneous arrays with skip-on-unknown cannot use synthesised `Codable`.
Required shape:

1. Decode each element into a raw wrapper exposing `type`, `id`, and its
   keyed container.
2. Look up `type` in the registry.
3. Hit → run the decode closure. Miss or throw → try `fallback` (one level).
   Fallback missing or also unknown → return `nil`.
4. `compactMap` drops the nils.

One code path covers unknown type and known-type-missing-prop. Must be unit
testable with no running app.

### 3.4 Performance tracker

- Timestamps captured **synchronously on the main actor** using
  `ContinuousClock.Instant`. Never `await` inside a measured interval.
- Completed sample structs are handed to the actor afterward.
- Marks: **T0** page container init · **T1** decoder returns · **T2** body
  returns · **T3** `CATransaction` completion on first content commit.
- Derived: decode = T1−T0, build = T2−T1, TTFR = T3−T0.
- Output: local JSON in the XCUITest bundle output directory. Supabase upload is
  optional dashboarding, not part of measurement.

#### Post-T3 marks

A single harness-driven scroll pass to the bottom of the page — not a second
launch, not a second scroll — produces four more marks, all optional until
that pass completes:

- **TTI** — first scroll gesture actually processed (`onScrollGeometryChange`
  firing with a changed offset), reported as `ttiMs` (TTI − T0). Includes
  event-injection latency from whatever drives the gesture (XCUITest in the
  harness); not a pure app-side number.
- **Per-section build** — every `SectionContainer` times its own `content()`
  build and reports it by position, giving `sectionBuildMs` (ordered array)
  and `fullPageBuildMs` (their sum). Both variants report 13 entries for
  `home_all.json` (rows 2–14 of §6's table; the header section is excluded,
  rendered separately as the pinned overlay).
- **Full-page wall time** — the last section's first commit, reported as
  `fullPageWallMs` (that instant − T0). Necessarily includes scroll duration
  — both screens use `LazyVStack`, so sections past the fold don't build
  until scrolled into view — and is therefore comparable only across runs
  driven with the same scroll cadence, not as an absolute render number.
- **Scroll perf** — a `CADisplayLink`-driven frame monitor running for the
  same window (TTI → last-section commit), reporting `scrollFrameCount`,
  `scrollDroppedFrames`, `scrollDroppedPct`, `scrollWorstFrameMs`,
  `scrollHitchMs`. A frame counts as dropped when its actual duration
  exceeds *its own* `targetTimestamp − timestamp` budget by more than 50% —
  read per-frame from `CADisplayLink`, never a fixed 60Hz constant, since
  these are ProMotion, variable-refresh-rate displays. The display link
  itself costs main-thread time and so slightly perturbs the frames it
  samples; this is a harness-run cost only (gated behind
  `SDUI_PERF_TRACKING`).

`isComplete` is `true` once all four are present. `completedSampleJSON` is
republished each time any mark lands, from T3 onward — the harness waits on
`isComplete`, not merely on the JSON existing.

**Not built:** a JSON-fetch-vs-parse-vs-view-build split finer than
`decodeMs`/`buildMs`. `BundlePayloadSource.loadPage` runs one `JSONDecoder`
pass and node mapping happens inside each node's own `init(from:)`
(`SectionDecoding.swift`) — parse and map are interleaved with no seam to
split on. `decodeMs` vs `buildMs` is the split this architecture supports.

---

## 4. SwiftUI implementation notes

Decided during design. Implement as written; do not re-explore.

### 4.1 Global

| Concern | Decision |
|---|---|
| Page scroll | `ScrollView` + `LazyVStack(spacing: 24)` |
| Section identity | `ForEach(sections, id: \.id)` — explicit, never index |
| Type erasure | Registry returns `AnyView`. Explicit ids restore list-level identity. |
| Rails | `ScrollView(.horizontal)` + `LazyHStack(spacing: 12)`, `.scrollTargetBehavior(.viewAligned)` when `snap` |
| Grids | Plain `VStack` + `HStack`. **Not** `LazyVGrid` — fixed 6 items, no benefit, known sizing quirks inside a lazy parent. |
| Grid row heights | Equal via `.fixedSize(horizontal:false, vertical:true)` on the row + explicit tile height. Ragged rows are a defect. |
| Width measurement | Once at page container, injected through `@Environment`. No nested `GeometryReader`. |
| Images | Custom cached async loader. **`AsyncImage` is prohibited** — no cache, refetches on redraw, poisons perf numbers. |
| Image placeholder | `surface.muted` rect at declared `aspect` so layout does not shift on load. |

### 4.2 Header

Highest implementation risk. Collapses from 280pt to 104pt.

- Offset tracking via **`onScrollGeometryChange`** (iOS 18). **Prohibited:**
  `GeometryReader` + `PreferenceKey` offset tracking — fires every frame,
  rebuilds the preference tree, primary cause of scroll jank.
- Expanded: location pill, avatar, search field, icon-chip rail (56pt circles,
  label below).
- Collapsed: search field, text-only tab strip with underline indicator.
- Same tab data drives both states. Selected tab: white fill + bold label
  (expanded), underline (collapsed).
- Tab strip is horizontally scrollable; 7 tabs, ~4.5 visible.

### 4.3 Carousel

- Hand-rolled on `ScrollView(.horizontal)` + `.scrollTargetBehavior(.viewAligned)`
  + `.scrollPosition(id:)`. **`TabView(.page)` is prohibited** — no loop support,
  eagerly materialises pages.
- `loop: true`: prepend last item and append first as buffers; reset
  `scrollPosition` at the boundary without animation.
- Exactly 2 items: duplicate the second so both edges show content.

### 4.4 Per-component

| Component | Container | Notes |
|---|---|---|
| `tile` | `ZStack(alignment:)` | Title top-leading, image bottom-trailing, `.clipShape(RoundedRectangle)`. Image may overflow the tile edge — clip. |
| `modelCard` | `ZStack` | Watermark digit behind image, `text.secondary` at ~0.25 opacity, large. Title/subtitle top-leading. |
| `iconTile` | `VStack` | `arch` shape = `UnevenRoundedRectangle` with large top radii, square bottom. Label below, 2 lines, centred. |
| `carCard` | `VStack` | Image with heart overlay top-trailing; overlay badge centred on the image's bottom edge, straddling the boundary. Spec chips wrap to one line, clipped. Dotted underline on tappable `priceNote`. |
| `placeCard` | `VStack` | Image pager `TabView(.page)` acceptable here (small, no loop). Notched overlay badge bottom-leading. Two buttons in an `HStack`, equal width. |
| `promoCard` | `ZStack` | Image trailing-aligned, may bleed to the card edge. Text leading. Optional logo row above the title. |
| `featureCard` | `HStack` | Image leading at fixed width, text trailing. Dashed `Divider` above the footer row. |
| `textBlock` | `VStack` | Leading-aligned, generous vertical padding. |

---

## 5. Static screen

**Full 14-section parity with the SDUI screen.** Any reduction invalidates the
performance comparison.

- Uses the **same leaf views** as SDUI, fed hardcoded Swift values.
- Renders the header with all 7 tabs. Non-`all` taps are **inert**.
- No decoder, no registry, no `PageStore` on this path.
- Data lives in a single `StaticHomeData.swift` mirroring `home_all.json`
  content exactly — same titles, prices, counts, order.

Rendering the same header in both variants is required for T0–T3 to be
comparable.

---

## 6. SDUI screen

Renders `home_all.json` via `BundlePayloadSource`.

Sections, in order:

| # | id | Container | Item | Notes |
|---|---|---|---|---|
| 1 | `app_header` | `header` | — | 7 tabs, pinned, collapsing |
| 2 | `buy_car_rail` | `rail` `sm` | `tile` | Header badge "Up to ₹80,000 off" |
| 3 | `sell_car_rail` | `rail` `sm` | `tile` | |
| 4 | `loans_rail` | `rail` `sm` | `iconTile` | `arch` shape |
| 5 | `car_check_grid` | `grid` 3 | `tile` | Fixed 3x2 |
| 6 | `used_cars_rail` | `rail` `lg` | `carCard` | `filter`: Wishlisted / Hot deals |
| 7 | `manage_vehicle_grid` | `grid` 3 | `tile` | Section band `surface.brand` |
| 8 | `orbit_promo` | `single` | `promoCard` | |
| 9 | `showrooms_rail` | `rail` `xl` | `placeCard` | |
| 10 | `trending_new_cars_rail` | `rail` `md` | `modelCard` | |
| 11 | `find_match_card` | `single` | `featureCard` | |
| 12 | `value_prop_carousel` | `carousel` | `promoCard` | `loop`, `peek` |
| 13 | `crashfree_promo` | `single` | `promoCard` | |
| 14 | `brand_footer` | `single` | `textBlock` | |

### 6.1 Other tabs

Six stub payloads, each one `single` section with a `textBlock` titled with the
tab name. Tapping a tab loads that `pageId`.

### 6.2 Navigation and sheets

All `navigate` and `openSheet` actions resolve to a single
**`DebugActionScreen`** displaying `type`, `target`, and `params`. No real
destinations are built. `call`, `openMaps`, `openUrl` invoke the system handler.

### 6.3 Fallback demo

`home_all_fallback_demo.json` — a copy of `home_all.json` with:
1. A section of unknown `type` (skipped entirely).
2. An unknown item type inside `buy_car_rail` **with** a `fallback` `tile`
   (fallback renders).
3. An unknown item type inside `buy_car_rail` **without** a `fallback` (skipped).
4. A `carCard` missing its mandatory `price` (skipped).
5. An item with `"action": {"type": "select", ...}` (renders, tap is a no-op).

---

## 7. Out of scope

Do not build, and do not ask to build:

- Bottom tab bar (Home / Activity / My Garage / Showrooms / Explore)
- Any real navigation destination or bottom sheet
- Login, OTP, forms, any authenticated flow
- Dark mode, Dynamic Type, localisation, RTL
- Android
- Field/production metrics collection
- CI gating on performance thresholds
