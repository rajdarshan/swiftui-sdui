# swiftui-sdui

A server-driven UI system for iOS: a SwiftUI client that renders home-screen
layouts from a versioned JSON schema, plus the payload package that describes
those screens. Stages 0–5 (tooling, design system, static screen, decoder,
SDUI rendering, performance harness) are built. Stage 6 (Supabase payload
source, GitHub Actions) is not yet implemented.

**Why the home screen:** it's the primary landing screen — the first thing a
user sees and the highest-interaction surface in the app. It's also the
most demanding layout to replicate: one vertical page scroll nests several
independent horizontal rails, a carousel, and a collapsing header that
tracks scroll offset in real time (`design_spec.md` §3.1, §4, §6). Proving
the SDUI architecture on the screen with the most nested scroll surfaces —
rather than a simpler one — is what makes the performance comparison in
`PERF.md` meaningful.

See `CLAUDE.md` for the full workflow and stage gates, `design_spec.md` for
design values and SwiftUI decisions, `COMPONENTS.md` for the schema contract,
`PerformanceMetric.md` for the performance harness, and `ADDING_A_COMPONENT.md`
before adding any component, prop, container, token, or action.

**Repo:** [github.com/rajdarshan/swiftui-sdui](https://github.com/rajdarshan/swiftui-sdui)
— see it for live commit history and the per-stage feature branches
(`leafComponents`, `SDUI`, `perfMetrics`, each merged to `main` via PR).

**walkthrough Demo:** `demo/demo.mp4` — a walkthrough of the main view, action handling,
a JSON payload change reflected live in the UI, and fallback handling. Download from git to check it.
## App Quick Demo
**Simulator Recorder Preview**

<img width="295" height="640" alt="SwiftUI-SDUI_app_demo" src="https://github.com/user-attachments/assets/70d23865-87e1-4fc3-b28e-191426e0e52a" />


## Setup

Requires iOS 18.0+ / Xcode 26.5. The Xcode project (`iOS/SwiftUISDUI.xcodeproj`)
is created and configured manually — nothing generates or modifies targets,
schemes, or build settings.

```
npm install                 # installs husky git hooks via `prepare`
```

Build:
```
xcodebuild -project iOS/SwiftUISDUI.xcodeproj -scheme SwiftUISDUI -configuration Debug clean build | xcbeautify
```

Test (pure logic only — decoder, fallback resolution, token/width math):
```
xcodebuild test -project iOS/SwiftUISDUI.xcodeproj -scheme SwiftUISDUI -destination 'platform=iOS Simulator,name=iPhone 16' | xcbeautify
```

Lint:
```
swiftlint
jq -e . sdui-config/payloads/*.json
```

### Why lint and conventional commits are enforced

`.husky/pre-commit` runs `swiftlint lint --strict` on staged Swift files
only, blocking the commit on any violation — style consistency is enforced
mechanically rather than left to review, since this is a multi-stage,
multi-branch project where several increments touch the same view/decoder
layers. The same hook runs `npm run validate --workspace=sdui-config`
whenever a `sdui-config/` file is staged, catching `COMPONENTS.md` §1
violations (nulls, raw hex/px, non-token values) before they ever reach a
payload file.

`.husky/commit-msg` runs `commitlint` against `commitlint.config.js`, which
hard-codes the same `type` and `scope` enums as `CLAUDE.md`'s commit
guidelines — the convention isn't just documented, it's mechanically
enforced. This matters beyond style: `sdui-config/.versionrc.json` drives
`standard-version`, which parses commit `type` to auto-generate
`sdui-config/CHANGELOG.md` and bump the payload package's `version` on
release, then propagates it into every payload via
`scripts/sync-version.mjs`. Structured commit messages are the direct input
to that automated content-versioning pipeline (see Versioning below), not
just a readability convention.

### Commit and branching strategy

One feature branch per stage/increment, merged into `main` through a
reviewed PR — e.g. `leafComponents`, `SDUI`, and `perfMetrics` were each
developed on their own branch and merged via PR
(`a955138 Merge pull request #3 from rajdarshan/perfMetrics`). This mirrors
`CLAUDE.md`'s workflow directly: one logical increment per commit, a
spec-compliance audit and human review gate at the end of each unit, and no
proceeding to the next unit without that review — the branch/PR boundary is
where that review actually happens.

## Architecture

```
PayloadSource (protocol, async)
  └── BundlePayloadSource (stages 1–5; SupabasePayloadSource is stage 6)
            │
      PayloadDecoder ──uses──> ComponentRegistry (decode closures)
            │
      PageStore (@Observable, @MainActor)   one per pageId
            │
      SDUIPageView ──> ComponentRegistry (view closures)
            │
      ActionHandler ──> Router / SheetPresenter / DebugActionScreen
```

Rules that shape it (`design_spec.md` §3.2):

- Nodes are value-type structs — no `ObservableObject`/`@Observable` per node.
- One `PageStore` per `pageId`, `@Observable`, `@MainActor`.
- The component registry is a **string-keyed dictionary**, not a Swift `enum`,
  so adding a component is one new file plus one registration line.
- Actions are data (`Action` values on nodes), never closures. `ActionHandler`
  is injected via `@Environment`.
- Leaf views are shared between the static and SDUI screens and take plain
  Swift values — never a JSON node, never the registry.
- Every node has a stable `id`; every `ForEach` uses it explicitly.
- `schemaVersion` never gates rendering — it's read and logged, not checked.

### Why MVVM and VIPER

The architecture takes working components from both patterns rather than
adopting either wholesale, because the server-driven problem has two
distinct concerns that each pattern solves separately.

**From MVVM:** a single observable state holder per screen — `PageStore`
plays the ViewModel role, owning `[SectionNode]`, filter selections, and
load state, while `SDUIPageView` stays a thin, declarative View. That
instinct is pushed down to component level too: leaf views take plain Swift
values only, never a node or the registry, so no view ever carries parsing
or business logic.

**From VIPER:** the Interactor/Entity/Router separation. `PayloadSource` +
`PayloadDecoder` act as the Interactor — fetch and decode, with no knowledge
of how anything renders. Nodes are Entities — inert value-type structs with
no behavior. `ActionHandler` is the Router — the one place a tap's *intent*
(`Action` data) resolves to an actual destination, fully decoupled from
whatever triggered it. The registry's decode-closure/view-closure split
plays a Presenter-like role per component type.

**Why the combination:** the central challenge here is heterogeneous,
server-declared data driving view construction, safely. VIPER's hard
Interactor/Entity boundary is what makes decode and fallback resolution unit
testable with no rendered hierarchy — exactly the executed-vs-compile-only
test split in `CLAUDE.md`. MVVM's single state holder per screen is what
keeps state from fragmenting into dozens of node-level observable objects,
which `design_spec.md` §3.2 calls out explicitly as the single biggest perf
risk this architecture avoids.

## Schema design rationale

`COMPONENTS.md` is the schema contract; the server and client split
responsibility deliberately: the server decides which sections render, in
what order, with what data, and the *intent* of a tap. The client owns layout
math, spacing, fonts, exact colors behind tokens, scroll physics, and what a
tap destination actually is. The server never describes a destination screen,
sheet contents, or a form — those are native.

Two consequences of that split:

- **Fallback is node-level, one level deep.** An unknown section type is
  skipped; an unknown item type renders its `fallback` if present and valid,
  else is skipped; a known type missing a mandatory prop follows the same
  path. A bad payload degrades but never blanks the page.
- **Extension prefers the smallest surface.** Add a prop to an existing item
  before a new item type, and a new item type before a new container — five
  containers (`rail`, `grid`, `carousel`, `list`, `single`) already cover
  every list-shaped layout on this screen.

## Versioning

Two independent numbers, per `COMPONENTS.md` §2:

| | `schemaVersion` | `version` |
|---|---|---|
| Answers | Which contract does this payload speak? | Which content revision is this? |
| Format | `major.minor` | semver |
| Bumped by | A human, editing `COMPONENTS.md` | `standard-version` on release |

A payload declares the *lowest* schema version that can render it — the
highest `Since` among the components it actually uses — so payloads
legitimately sit at different versions across the same release.

**Backward compatibility when a new component type is added:** this is a
minor bump (`1.x` → `1.x+1`), because it's additive — an older client that
doesn't recognize the new `type` string simply skips that section or item
(per the fallback rules above) and renders every sibling it does understand.
Degraded, never blank, and never gated by a version check — `schemaVersion` is
diagnostic only. Contrast with a **major** bump (renaming or removing an
existing type, or changing what a prop means): an old client renders that
node *wrongly*, not just partially, which is why major bumps are restricted
to a narrow list and treated as expensive. `COMPONENTS.md` §11 sketches the
worked example — a planned `chipGroup` section — as an additive, minor,
backward-compatible change of exactly this shape.

## Trade-offs

- **No `AsyncImage`.** A custom cached loader is used instead — `AsyncImage`
  has no cache and refetches on redraw, which would poison performance
  numbers.
- **No `GeometryReader` inside a rail, grid cell, or lazy row.** Available
  width is measured once at the page container and injected via
  `@Environment`.
- **No `LazyVGrid` for the fixed 3×2 grids** — plain `VStack`/`HStack` avoids
  known sizing quirks inside a lazy parent for a fixed item count with no
  laziness benefit.
- **`TabView(.page)` is banned for the value-prop carousel** (no loop
  support, eagerly materializes pages) but permitted for the small,
  non-looping `placeCard` image pager.
- **`fullPageWallMs` (perf harness) necessarily includes scroll duration** —
  both screens use `LazyVStack`, so below-the-fold sections don't build until
  scrolled into view. Comparable only across runs with the same scroll
  cadence, not as an absolute render number.
- **Major schema bumps are an accepted risk, not a hard failure.** Because
  `schemaVersion` never gates rendering, an old client hitting a major-bump
  payload renders silently wrong rather than refusing to render — the
  tradeoff for never blanking a screen on a minor mismatch.
- **Dark mode, Dynamic Type, and localisation are explicitly out of scope**
  (`design_spec.md` §7), as is CI gating on performance thresholds — the
  perf harness is a local development tool with no enforced numeric
  threshold.
