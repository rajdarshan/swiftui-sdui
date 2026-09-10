# swiftui-sdui

**A server-driven UI system for iOS.** A SwiftUI client renders a complete car-marketplace home screen — collapsing header, seven tabs, nested horizontal rails, a looping carousel, grids, filter chips — from a versioned JSON payload. Change the JSON, the screen changes. No app release.

The same screen is also built by hand in Swift, so the cost of doing it this way is measured rather than assumed. It's **about 30ms** at first render.

![Platform](https://img.shields.io/badge/platform-iOS%2018%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![Schema](https://img.shields.io/badge/schema-1.0-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

<!-- Commit the gif to docs/demo.gif — the current private-user-images URL is signed, expires, and renders broken for every visitor. -->
![Demo: a payload edit reflected live in the UI](demo/demo.gif)

*Longer walkthrough — action handling, a live payload edit, fallback behaviour: [`demo/demo.mp4`](demo/demo.mp4)*

---

## Contents

- [Where the boundary sits](#where-the-boundary-sits)
- [The payload](#the-payload)
- [The contract](#the-contract)
- [Fallback strategy](#fallback-strategy)
- [Versioning](#versioning)
- [Performance](#performance)
- [Architecture](#architecture)
- [Why the home screen](#why-the-home-screen)
- [Setup](#setup)
- [Adding a component](#adding-a-component)
- [Trade-offs and limits](#trade-offs-and-limits)
- [Roadmap](#roadmap)

## Where the boundary sits

Server-driven UI means the backend sends a description of the screen, not just data for it. The app ships a generic renderer; layout, ordering, and content live in a payload the server controls.

Rendering JSON is the easy part. The design question is **where you draw the boundary** — and published systems drew it in different places. Airbnb's Ghost Platform drew it around reusable sections; Lyft's around product-named components; Netflix's CLCS around versioned components with guaranteed baseline fallbacks. Spotify's HubFramework was deprecated because the abstraction cost more than it returned.

This system draws it here:

| The server decides | The client decides |
| --- | --- |
| Which sections, in what order | Layout maths, spacing, safe areas |
| Which item type, and its data | Fonts, exact colours behind tokens |
| The *intent* of a tap (`type` + `target`) | What the destination actually is |
| Which chip is selected by default | Scroll physics, snapping, animation |
| Presence or absence of a node | Header collapse behaviour |

**The server never describes a destination screen, a bottom sheet's contents, a form, or a validation rule.** Login, add-vehicle, city-picker, and price-breakup are fully native. The server names them with `openSheet` and nothing more.

That's the load-bearing decision. It keeps payloads small, keeps navigation typed and testable in Swift, and means a payload can never inject behaviour — only content and intent.

Two rules that follow from it, enforced by a pre-commit validator:

- **No layout numbers in a payload.** No widths, heights, margins, font sizes. The server names intent; the client owns geometry.
- **No raw colours.** Token names only. Also no `null` — absent keys are simply omitted.

## The payload

One file per top-level tab, indexed by a manifest.

```json
{
  "schemaVersion": "1.0",
  "version": "1.4.2",
  "pageId": "home_all",
  "sections": [
    {
      "id": "trending-new-cars",
      "type": "rail",
      "header": { "title": "Trending new cars" },
      "itemWidth": "md",
      "items": [
        {
          "id": "model-tata-nexon",
          "type": "modelCard",
          "title": "Tata Nexon",
          "subtitle": "₹8.00 - 15.60 Lakh",
          "image": { "url": "https://…", "aspect": 1.6 },
          "action": { "type": "navigate", "target": "model_detail",
                      "params": { "modelId": "tata-nexon" } },
          "fallback": { "id": "model-tata-nexon-fb", "type": "tile",
                        "title": "Tata Nexon",
                        "action": { "type": "navigate", "target": "model_detail" } }
        }
      ]
    }
  ]
}
```

Prices, distances, and dates arrive **display-ready**. The client never formats a currency or computes a string — that's server work, and keeping it there is what makes the client purely a renderer.

## The contract

Schema **1.0**. Six containers, eight item types, eight action types, 21 colour tokens.

### Containers

| Type | Props | Used for |
| --- | --- | --- |
| `rail` | `items[]`, `itemWidth`, `snap` | Buy car, Sell your car, Get loans, Used cars, Showrooms, Trending |
| `grid` | `items[]`, `columns` (2–4) | Car check services, Manage your vehicle |
| `carousel` | `items[]`, `loop`, `peek`, `autoScrollMs` | Value-prop carousel |
| `list` | `items[]` | Reserved — unused on this screen |
| `single` | `item` | Partner promo, find-your-match, safer-roads, footer |
| `header` | `search`, `tabs`, `location`, `avatar` | Pinned app header, 7 tabs |

Every section carries `id` and `type`; `header`, `style`, and `filter` are optional. `filter` supplies chips whose selection swaps the container's items — selection state is local to the section, and all chips' items ship upfront.

### Item types

Every item carries `id` (mandatory, page-scoped) and may carry `fallback`.

| Type | Mandatory | Optional |
| --- | --- | --- |
| `tile` | `title`, `action` | `image`, `style` |
| `modelCard` | `title`, `image`, `action` | `subtitle`, `watermark`, `style` |
| `iconTile` | `label`, `image`, `action` | `imageShape` (`circle`/`arch`/`square`) |
| `carCard` | `image`, `title`, `price`, `action` | `overlayBadge`, `favorite`, `subtitle`, `specs[]`, `priceSuffix`, `priceNote`, `trustBadges[]` |
| `placeCard` | `images[]` (min 1), `title` | `overlayBadge`, `subtitle`, `linkRow`, `status`, `buttons[]` (0–2) |
| `promoCard` | `title` | `image`, `eyebrow`, `subtitle`, `logos[]`, `button`, `style` |
| `featureCard` | `title` | `body`, `image`, `imagePosition`, `badge`, `footer` |
| `textBlock` | `title` | `subtitle`, `style` |

Not every item fits every container — `promoCard` is carousel/single only, `textBlock` is single only, and a `fallback` must itself be valid in its parent container. The full matrix is enforced by the validator, not left to convention.

### Actions

`{ type, target, params }` — `params` is a flat string map, no nesting, no arrays.

`navigate` · `openSheet` · `toggle` · `call` · `openMaps` · `openUrl` · `search` are handled. `select` is **documented but deliberately unhandled** — it exists to exercise the unknown-action no-op path, and is the seam for a future standalone chip group.

### Tokens

Colour (`brand.primary`, `surface.muted`, `tile.blue`, `text.accent`, …), text style (`display`, `sectionTitle`, `cardTitle`, `price`, …), corner radius (`none`/`sm`/`md`/`lg`/`pill`), and icons mapped to SF Symbols. Payloads never contain emoji literals or hex.

Item width is a token naming a **peek ratio** — how many items are visible across the viewport. The server names a size; the client owns the arithmetic:

| Token | Visible items |
| --- | --- |
| `sm` | 3.25 |
| `md` | 2.5 |
| `lg` | 1.6 |
| `xl` | 1.3 |
| `full` | 1.0 |

## Fallback strategy

There are only two fallback mechanisms in SDUI, trading off against each other:

- **Server-side** — the payload carries a simpler alternate representation. Behaviour changes without an app release, but the payload grows.
- **Client-side default** — the client substitutes something generic for anything it doesn't recognise. Payload stays small, but changing behaviour needs a release.

This system uses server-side fallback with a client-side skip as the floor, resolved **node-level and exactly one level deep**:

| Situation | Behaviour |
| --- | --- |
| Unknown section `type` | Section skipped, siblings render |
| Unknown item `type`, `fallback` present and known | Fallback renders in its place |
| Unknown item `type`, no usable `fallback` | Item skipped, container renders the rest |
| Known type, missing mandatory prop | Same path — try `fallback`, else skip |
| `fallback` itself unknown, or nested twice | Ignored, item skipped |
| Unknown `action.type` | Node renders, tap logs and does nothing |
| Unknown token | Client default substituted |
| `defaultChipId` matches no chip | Falls back to index 0 |
| Duplicate item `id` on a page | Logged, last wins — the validator should catch it first |
| Image load failure | Slot collapses, text still renders |
| `schemaVersion` above the client's max | Renders best-effort. Never gates |

One level deep is deliberate. Recursive fallback makes the failure mode unbounded and untestable; capping it means every degradation path above is enumerable and unit-tested with no rendered hierarchy.

**The guarantee: a bad payload degrades. It never blanks a page.**

`home_all_fallback_demo.json` exercises every row of that table — it's the fastest way to see the behaviour rather than read about it.

## Versioning

Two independent numbers, never sharing a value.

| | `schemaVersion` | `version` |
| --- | --- | --- |
| Question | Which **contract** does this payload speak? | Which **content revision** is this? |
| Format | `major.minor`, e.g. `"1.0"` | semver, e.g. `"1.4.2"` |
| Owned by | The contract document | `sdui-config/package.json` |
| Bumped by | A human, when the contract changes | `standard-version` on release |
| Changes when | A type, prop, or token changes | Copy, prices, ordering, images change |

**A payload declares the lowest schema version that can render it** — the highest `Since` among everything it actually uses. Consequence: payload versions are *unequal across files by design*. The six stub pages sit at `1.0` long after the main page has moved on, and the manifest's top-level number is the highest in use, not a value imposed downward. The validator enforces this from a feature→`Since` table; drop a payload's declared version below what it uses and validation fails.

**Minor** (`1.0` → `1.1`) is additive: a new component, a new optional prop, a new token, action, container, or enum case. An older client skips what it doesn't know and renders the rest.

**Major** (`1.x` → `2.0`) is breaking: removing or renaming anything, promoting an optional prop to mandatory, or changing what a prop means. An old client renders that node *wrongly* rather than partially.

**`schemaVersion` never gates rendering.** It's read and logged, never checked. Its purposes are diagnostic: how many sessions render payloads above their client's max, and whether a missing section is a schema gap or a bug. Because it doesn't gate, a schema bump can never blank a screen — the price being that a major bump reaching an old client produces silently-wrong output instead of a hard failure. That's exactly why the major list is kept narrow.

`version` is never hand-edited. `standard-version` parses conventional commit types, bumps the package, writes the changelog, and a sync script propagates the number into the manifest and every payload. Structured commit messages are the direct input to that pipeline — which is why `commitlint` runs in a git hook rather than living in a style guide.

## Performance

Real measurements from `ScreenPerformanceHarnessTests` — the same screen built twice, sharing identical leaf views, so the delta isolates decode and registry dispatch.

**Method:** physical iPhone (`iPhone14,5`, iOS 26.6), **Release** build, 5 back-to-back runs per variant in one session. Marks run T0 (container init) → T1 (decode returns) → T2 (body returns) → T3 (first commit), then one scripted scroll pass. Raw JSON for every run is committed under `perf-output/runs/`.

Mean, with min–max across 5 runs, in ms:

| Metric | Static | SDUI | Overhead |
| --- | --- | --- | --- |
| `decodeMs` | 0 — no decoder on this path | **19.9** (12.3–37.6) | ~20ms absolute |
| `buildMs` | 0.69 (0.58–1.15) | 3.38 (1.98–7.19) | +2.7ms |
| `ttfrMs` — time to first render | 52.1 (47.5–57.2) | **81.8** (61.6–131.8) | **+29.7ms (+57%)** |
| `ttiMs` — time to interactive | 33.1 (29.3–39.6) | **61.0** (44.1–106.8) | **+27.9ms (+84%)** |
| `fullPageWallMs` | 12710.9 | 12828.6 | +117.7ms (+0.9%) |
| `scrollDroppedPct` | 3.39% | 3.49% | within run-to-run spread |
| `scrollHitchMs` | 555.8 | 572.6 | +3.0% |
| `scrollWorstFrameMs` | 109.9 | 114.5 | +4.2% |

**Reading this honestly.**

The percentages look alarming and the absolute numbers don't. Both variants render well under 150ms even at the worst point of the spread; SDUI's median TTFR sits nearer 70ms. The right sentence is *"SDUI costs about 30ms more than hardcoding the same screen"* — not *"SDUI is slow."* `buildMs` is the clearest case: +390% on a base of 0.69ms is a rounding error dressed as a catastrophe.

`ttfrMs` and `ttiMs` are the cleanest signals because they isolate pre-scroll cost. `fullPageWallMs` is dominated by ~12.7s of scripted scrolling on both variants — `LazyVStack` means below-the-fold sections build on scroll, not at launch — so it's comparable only across runs with matched scroll cadence, never as an absolute render number.

**Scroll performance is unaffected.** Dropped frames, hitch time, and worst frame all move by low single digits between variants, inside the noise on this device. The decoder and registry dispatch are a startup cost, not an ongoing one.

**Two caveats stated rather than buried.** Run 1's SDUI figures (`ttfrMs` 131.8, `decodeMs` 37.6) are the visible high end of the spread — first test in the session, plausibly cold caches and a first `JSONDecoder` pass. It's kept in the dataset, not dropped, and both the mean and the range reflect it. And `ttiMs` reading lower than `ttfrMs` reflects how the two marks are defined in the harness rather than interactivity genuinely preceding first paint; the relationship is consistent across both variants, so the *delta* is the usable number.

One device, one day, five runs. A snapshot with visible spread, not a powered study — which is why the ranges are published alongside the means.

**No render-path optimisation has been attempted against these numbers.** This is a baseline, not a before/after report. The one performance decision that predates it was designing `GeometryReader` out of every rail, grid cell, and lazy row up front — a nested `GeometryReader` recalculates on every appearance, so item width is measured once at the page container and injected via `@Environment` instead. That cost was avoided by design rather than found by profiling.

## Architecture

```
PayloadSource (protocol, async)
  └── BundlePayloadSource
            │
      PayloadDecoder ──uses──> ComponentRegistry (decode closures)
            │
      PageStore (@Observable, @MainActor)   one per pageId
            │
      SDUIPageView ──> ComponentRegistry (view closures)
            │
      ActionHandler ──> Router / SheetPresenter / DebugActionScreen
```

The registry is the core: a **string-keyed dictionary**, not a Swift `enum`. Each entry pairs a decode closure with a view closure. A dictionary rather than an enum means adding a component is one new file plus one registration line, with no exhaustive-switch churn — and no compile error when the server sends a type this build has never heard of. **If adding a component takes more than one line in the registry, the registry is wrong.** That's the design target, and it holds today.

**Invariants:**

- Nodes are value-type structs. No `ObservableObject` or `@Observable` per node — that fragmentation is the single largest performance risk in this architecture.
- One `PageStore` per `pageId`, `@Observable`, `@MainActor`. It owns sections, chip selection, and load state.
- Actions are `Action` values on nodes, never closures. `ActionHandler` is injected via `@Environment`.
- Leaf views take plain Swift values — never a JSON node, never the registry. They're shared unchanged between the hand-built static screen and the SDUI screen, which is what makes the performance comparison a fair one rather than two different screens racing.
- Every node has a page-scoped stable `id`; every `ForEach` uses it explicitly.

<details>
<summary><strong>Why elements of both MVVM and VIPER</strong></summary>

The server-driven problem has two concerns these patterns solve separately.

**From MVVM:** one observable state holder per screen. `PageStore` is the ViewModel; `SDUIPageView` stays thin and declarative. The same instinct runs to leaf level — components take plain values, so no view carries parsing or business logic.

**From VIPER:** the Interactor/Entity/Router separation. `PayloadSource` + `PayloadDecoder` are the Interactor — fetch and decode, with zero knowledge of rendering. Nodes are Entities: inert, no behaviour. `ActionHandler` is the Router — the single place a tap's intent resolves to a destination.

**Why both:** VIPER's hard Interactor/Entity boundary is what makes decode and fallback resolution unit-testable with no rendered view hierarchy — every row of the fallback table is an executed test, not a UI test. MVVM's single state holder is what stops state fragmenting into dozens of node-level observable objects. The registry's decode-closure/view-closure split plays a Presenter-like role per component type.

</details>

### Debuggability

The defining support cost of SDUI is that two users on the same build can see entirely different screens. Every render logs component type alongside the payload's `schemaVersion`, `version`, and the client build — all three variables have to be identifiable at once or a report is unreproducible.

Fallback resolution logs too. A skipped node is a silent visual absence by design; without a log line, a section quietly missing in production is undiagnosable. `DebugActionScreen` renders the resolved destination for any action rather than navigating, so action wiring is verifiable without walking the navigation graph.

## Why the home screen

Two reasons, and the second matters more.

**It's the hardest layout to replicate.** One vertical page scroll nesting several independent horizontal rails, a carousel, a filtered grid, and a pinned header that collapses against scroll offset in real time. Proving the architecture on the screen with the most nested scroll surfaces — rather than a simpler one — is what makes the performance comparison meaningful.

**It's the right blast radius.** SDUI belongs on high-churn, low-risk surfaces — home feeds, merchandising, promos — while critical flows stay native. A server-side mistake on the home screen costs a degraded rail. The same mistake in a payment flow costs money. That's why the schema deliberately can't express a form, a validation rule, or a sheet's contents. Picking home is the architecture decision, not just the demo choice.

## Setup

**Requires:** iOS 18.0+, Xcode 26.5, Node 20+, [SwiftLint](https://github.com/realm/SwiftLint), [jq](https://jqlang.github.io/jq/), [xcbeautify](https://github.com/cpisciotta/xcbeautify).

The Xcode project is configured manually — nothing generates or rewrites targets, schemes, or build settings.

```bash
git clone https://github.com/rajdarshan/swiftui-sdui.git
cd swiftui-sdui
npm install    # installs the husky git hooks via `prepare`
```

**Build**

```bash
xcodebuild -project iOS/SwiftUISDUI.xcodeproj -scheme SwiftUISDUI \
  -configuration Debug clean build | xcbeautify
```

**Test** — decoder, registry, fallback resolution, token and width maths. Pure logic; no rendered hierarchy required.

```bash
xcodebuild test -project iOS/SwiftUISDUI.xcodeproj -scheme SwiftUISDUI \
  -destination 'platform=iOS Simulator,name=iPhone 16' | xcbeautify
```

**Validate payloads** — catches version drift, unknown tokens, duplicate ids, container mismatches, nulls, raw hex.

```bash
npm run validate --workspace=sdui-config
```

**Run the performance harness** (physical device, Release):

```bash
iOS/scripts/run-perf-harness.sh 'platform=iOS,id=<device-id>' Release
```

### See it work

- **Change the UI without touching Swift.** Edit any file in `sdui-config/payloads/`, rebuild, and the screen reflects it.
- **See fallback resolution.** Load `home_all_fallback_demo.json` — it contains unknown types with and without `fallback` nodes.
- **See old-client behaviour.** Comment out one line in `ComponentRegistry.swift`, rebuild. That component's fallback renders in its place and the page is otherwise intact. No crash, no blank screen.

### Repo layout

```
iOS/
  SwiftUISDUI/
    Models/Items/         node structs — value types, Codable
    Components/           leaf views — plain values only
    Registry/             ComponentRegistry.swift
    Static/               the hand-built comparison screen
  scripts/                perf harness runner
sdui-config/
  config.json             manifest: schema + content version, payload index
  payloads/               home_all.json, six tab stubs, fallback demo
  scripts/                validate-payloads.mjs, sync-version.mjs
perf-output/runs/         raw JSON, 5 runs per variant
demo/                     walkthrough recording
docs/                     images used by this README
```

### Enforcement

A pre-commit hook runs `swiftlint lint --strict` on staged Swift files and the payload validator on any staged `sdui-config/` change, blocking the commit on violation. A commit-msg hook runs `commitlint`. Style consistency is mechanical, not left to review — which matters in a multi-branch project where several increments touch the same view and decoder layers.

Work lands one feature branch per stage, merged to `main` through a reviewed PR — `leafComponents`, `SDUI`, and `perfMetrics` each went that way.

## Adding a component

**First, don't.** Work down this list and stop at the first yes:

| Ask | If yes |
| --- | --- |
| Can an existing item render this with data alone? | Write JSON. No code. |
| With one new **optional** prop? | Add the prop. Minor bump. |
| Is it the same item in a different **style**? | Use `style` tokens. |
| Same item in a different **layout**? | Change the container or `itemWidth`. |
| Is the layout itself new? | New **container**. Rare — think hard. |
| None of the above | New **item type**. |

Two anti-patterns this guards against. **Prop creep:** if an item would gain three or more optional props most call sites ignore, split it — `modelCard` exists because `tile` was heading that way. **Premature types:** one screen needing something slightly different isn't enough. Two screens is a signal.

**If a new type is warranted**, the order is contract first, client second, payload last: bump the schema version and add the type to the contract, add its `Since` entry and container matrix row to the validator in the *same commit*, then the node struct, the leaf view, one registry line, and finally raise `schemaVersion` only on the payloads that actually use it.

Prop design rules: mandatory means the component is *meaningless* without it — over-mandating forces major bumps later. Every optional prop needs a stated absent-behaviour. No layout numbers, no colours, flat `params`, and strings pre-formatted server-side.

**The verification step people skip:** remove the registration line, rebuild, and confirm the page renders without that component and doesn't crash. That's the old-client path, and it's the one worth running every time.

The full runbook, including a worked example of adding a `videoTile` at 1.1, lives in `ADDING_A_COMPONENT.md`.

## Trade-offs and limits

- **No `AsyncImage`.** A custom cached loader instead. `AsyncImage` has no cache and refetches on redraw, which would have poisoned the numbers above.
- **No `GeometryReader` inside a rail, grid cell, or lazy row.** Width is measured once at the page container and injected via `@Environment`. Every rail shares one container-measured width instead of each item sizing itself — a fixed one-time layout cost in place of a per-frame one.
- **No `LazyVGrid` for the fixed grids.** Plain `VStack`/`HStack` avoids known sizing quirks inside a lazy parent, with no laziness benefit at a fixed item count.
- **`TabView(.page)` is banned for the value-prop carousel** — no loop support, and it eagerly materialises pages. It's permitted for the small non-looping image pager inside `placeCard`.
- **All filter chips' items ship upfront.** Fine at two chips of ~three cards each; needs revisiting at larger fan-out.
- **Major schema bumps are an accepted risk, not a hard failure.** Since `schemaVersion` never gates, an old client hitting a major-bump payload renders silently wrong rather than refusing. That's the price of never blanking a screen on a minor mismatch.
- **No offline cache.** `BundlePayloadSource` reads from the app bundle, so the question hasn't arisen yet. A remote source needs last-known-good caching before it ships.
- **Some colour tokens are provisional.** Most are pixel-sampled and exact; a handful (`tile.creamBorder`, `tile.dark`, and the text greys) are reasoned from context.
- **Out of scope:** dark mode, Dynamic Type, localisation, and any CI gate on performance thresholds. The harness is a local development tool with no enforced number.

## Roadmap

Stages 0–5 are complete: tooling, design system, static reference screen, decoder, SDUI rendering, performance harness.

- [ ] **Remote payload source** — `SupabasePayloadSource` replacing the bundle source
- [ ] **Last-known-good caching**, so the screen survives a cold start with no network
- [ ] **CI** — payload validation and release automation on PR
- [ ] **`chipGroup` section at 1.1** — standalone chip groups emitting `select` against a sibling section, plus `datasets` on containers. An old client skips the unknown section and renders the container at its default dataset. The worked example of an additive minor bump.

## License

MIT — see [LICENSE](LICENSE).
