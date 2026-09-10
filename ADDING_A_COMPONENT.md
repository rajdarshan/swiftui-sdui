# Adding a Component

Runbook for extending the SDUI system. Follow it in order — the sequence matters,
because the contract must be settled before any code is written against it.

Related: `COMPONENTS.md` (the contract) · `design_spec.md` (design and
architecture) · `CLAUDE.md` (workflow and prohibitions)

---

## 0. Do you actually need a new component?

Work down this list and stop at the first "yes". Adding a type is the most
expensive option and the one most likely to bloat the registry.

| Ask | If yes |
|---|---|
| Can an existing item render this with data alone? | Write JSON. **No code.** |
| Can an existing item render it with a new **optional** prop? | Add the prop. Minor bump. Cheapest code change. |
| Is it an existing item with a different **style**? | Use `style` tokens. Add a colour token if needed. No new type. |
| Is it an existing item in a different **layout**? | Change the container or `itemWidth`. No new type. |
| Is the layout itself new (not a rail/grid/carousel/list/single)? | New **container**. Rare — think hard first. |
| None of the above | New **item type**. Continue below. |

Two anti-patterns to watch for:

- **Prop creep.** If an existing item would gain 3+ optional props that most
  call sites ignore, split it into a new type instead. `modelCard` exists
  because `tile` was heading this way.
- **Premature types.** One screen needing something slightly different is not
  enough. Two screens is a signal.

---

## 1. Describe the component before writing anything

Write this out first — in the PR description, an issue, or a scratch file. If
you can't fill every row, the design isn't settled and code will encode the
ambiguity.

### 1.1 Schema description

```markdown
## <componentName>

**Purpose:** one sentence — what it shows and why an existing type can't.
**Screen mapping:** which section(s) of which screen use it.
**Containers:** which of rail / grid / carousel / list / single it is valid in.
**Since:** the schema version introducing it.

| Prop | Type | Req | Description |
|---|---|---|---|
| `title` | string | M | ... |
| `subtitle` | string | O | Absent → row omitted, layout collapses. |

**Actions:** which action types it emits, and from which sub-element.
**Tokens used:** existing tokens; list any new ones separately.
**Degradation:** what an old client shows instead. Does it need a `fallback`
in payloads, and if so, of what type?
```

Rules for prop design:

- **Mandatory means the component is meaningless without it.** Everything else
  is optional. Over-mandating breaks old payloads and forces major bumps later.
- **Every optional prop needs a defined absent-behaviour.** "Absent → hidden" is
  fine; unstated is not.
- **No layout numbers.** No widths, heights, margins, or font sizes. The server
  names intent; the client owns geometry.
- **No colours.** Token names only.
- **Pre-format strings server-side.** Currency, distances, dates arrive display-ready.
- **Flat `params`.** No nested objects or arrays in actions.

### 1.2 Design description

```markdown
**Container:** ZStack / VStack / HStack, and alignment.
**Element order:** what sits where, including overlays and z-order.
**Fixed dimensions:** image aspect, fixed heights — added to design_spec.md §2.5.
**Text styles:** which tokens, with line limits.
**Tokens:** background, foreground, border, radius.
**Interaction:** what is tappable; whole-card or sub-elements.
**Edge cases:** longest plausible string, missing image, empty optional arrays.
**SwiftUI note:** the specific view/API to use, and anything prohibited here.
```

The SwiftUI note is what stops rediscovery later. Be concrete: *"image pager
uses `TabView(.page)` — permitted here because there's no loop"* beats *"shows
multiple images"*.

---

## 2. Classify the version bump

Per `COMPONENTS.md` §2.1:

| Change | Bump |
|---|---|
| New component, container, action, token, icon | **Minor** — `1.0` → `1.1` |
| New optional prop on an existing component | **Minor** |
| New enum case on an optional field | **Minor** |
| Renaming or removing anything | **Major** — `1.x` → `2.0` |
| Optional prop becomes mandatory | **Major** |
| Meaning or type of an existing prop changes | **Major** |

Adding a component is always minor. If you find yourself reaching for major,
stop — prefer adding a new optional prop or a new type over redefining one.

---

## 3. File changes

In this order. Contract first, client second, payload last.

### 3.1 Contract — `COMPONENTS.md`

| Section | Change |
|---|---|
| Header block | Bump `Schema version:` |
| §8 item table | New row: type, `Since`, full prop list |
| §8 screen mapping | Add the mapping line |
| §12 matrix | New row marking valid containers |
| §5 tokens | Any new colour / icon / text-style token |
| §14 history | New row: version, date, change, minor or major |

### 3.2 Validator — `sdui-config/scripts/validate-payloads.mjs`

**Same commit as §3.1. these must not drift — the validator's `Since` table and the contract are updated in the same commit.**

```js
const SINCE = {
  item: {
    ...,
    videoTile: '1.1'        // ← new
  }
};

const MATRIX = {
  rail: new Set([..., 'videoTile']),   // ← valid containers
};
```

New colour tokens go in `COLOURS`, icons in `ICONS`, actions in `SINCE.action`.

### 3.3 Design — `design_spec.md`

| Section | Change |
|---|---|
| §2.1 | New colour tokens with hex |
| §2.5 | Any fixed dimension the component needs |
| §2.7 | New icon token → SF Symbol mapping |
| §4.4 | New row in the per-component table with the SwiftUI note |
| §6 | If it appears on the SDUI screen, add it to the section table |

### 3.4 Client

| File | Change |
|---|---|
| `iOS/SwiftUISDUI/Models/Items/<Name>Node.swift` | Node struct — value type, `Codable`, `id` + `type` |
| `iOS/SwiftUISDUI/Components/<Name>View.swift` | Leaf view taking plain values, never a node or the registry |
| `iOS/SwiftUISDUI/Registry/ComponentRegistry.swift` | **One registration line** — decode closure + view closure |
| `iOS/SwiftUISDUI/Static/StaticHomeData.swift` | Only if the static screen shows it, for parity |

If adding a component takes more than one line in the registry, the registry is
wrong. That's the design goal.

### 3.5 Payload

| File | Change |
|---|---|
| `payloads/<page>.json` | Use the component; raise that payload's `schemaVersion` to the new version |
| `config.json` | Matching per-entry `schemaVersion`; top-level = highest in use |

Only raise the payloads that actually use it. Untouched payloads keep their old
number — that is the point of §2.2.

---

## 4. Commands

```bash
# 1. Validate the payloads — catches version drift, unknown tokens,
#    duplicate ids, container mismatches, nulls
npm run validate --workspace=sdui-config

# 2. Build
xcodebuild -project iOS/SwiftUISDUI.xcodeproj -scheme SwiftUISDUI -configuration Debug clean build | xcbeautify

# 3. Run the executed tests (decoder, registry, fallback, tokens)
xcodebuild test -project iOS/SwiftUISDUI.xcodeproj -scheme SwiftUISDUI \
  -destination 'platform=iOS Simulator,name=iPhone 16' | xcbeautify

# 4. Lint
swiftlint --strict

# 5. Commit — husky runs validate + swiftlint on staged changes,
#    commitlint checks the message
git add -A
git commit -m "feat(sdui-config): add videoTile component at schema 1.1"
```

### Releasing a content change

`schemaVersion` is bumped **by hand** in the files above. `version` is machine-managed:

```bash
# Bumps sdui-config/package.json, writes CHANGELOG.md, tags,
# and runs sync-version.mjs to propagate into config.json + every payload
npm run release --workspace=sdui-config

# Force a level
npm run release:minor --workspace=sdui-config
npm run release:major --workspace=sdui-config

# Re-sync by hand if package.json and the payloads ever disagree
npm run sync:version --workspace=sdui-config
```

**Never edit `version` by hand.** The validator fails if `config.json`
`releaseVersion` and `package.json` disagree, which is your signal to run
`sync:version`.

---

## 5. Verification checklist

| Check | How |
|---|---|
| Payloads valid | `npm run validate` exits 0 |
| Version enforcement | Temporarily lower the payload's `schemaVersion` — validation must fail |
| Builds | `xcodebuild build` clean |
| Logic tests pass | `xcodebuild test` green |
| Renders | Simulator, visually compared against the reference |
| Unknown-type fallback | Add it to `home_all_fallback_demo.json` with and without a `fallback` |
| Old-client behaviour | Remove the registration line, rebuild — page must render without it, no crash |
| Static parity | If on the static screen, both variants match |
| Spec compliance | Run the `spec-compliance` subagent |

The old-client test is the one people skip and the one the assignment explicitly
asks you to demonstrate. Do it every time.

---

## 6. Worked example — `videoTile` at 1.1

**Describe.** A tile with a looping muted video instead of a still. Existing
`tile` can't: no video, no play affordance, different aspect. Valid in `rail`
only. Emits `navigate` on tap.

| Prop | Type | Req | Description |
|---|---|---|---|
| `title` | string | M | Overlay label, top-leading |
| `videoUrl` | string | M | Absolute, mp4 |
| `posterImage` | ImageRef | O | Shown until first frame. Absent → `surface.muted`. |
| `style` | Style | O | |
| `action` | Action | M | |

Old clients: skip it, so payloads must ship a `fallback` `tile` with
`posterImage` as its image.

**Classify.** New component → minor → `1.0` → `1.1`.

**Change.** `COMPONENTS.md` header + §8 + §12 + §14 · validator `SINCE.item`
and `MATRIX.rail` · `design_spec.md` §4.4 · `VideoTileNode.swift` +
`VideoTileView.swift` + one registry line · `home_all.json` uses it and moves to
`"1.1"`, `config.json` entry and top-level to `"1.1"`.

**Verify.** `npm run validate` → passes. Drop the payload back to `"1.0"` →
fails with *"declares schemaVersion 1.0 but uses features from 1.1"*. Restore.
Build, test, run in simulator. Comment out the registry line → the fallback
`tile` renders in its place. Uncomment.

**Commit.**

```bash
git commit -m "feat(sdui-config): add videoTile component at schema 1.1"
git commit -m "feat(ios): render videoTile with poster fallback"
```

---

## 7. Timed additions

The critical-path order is:

1. **Register first, render crudely.** Get the type recognised and a placeholder
   on screen. Proves the registry seam works.
2. **Then the real view.** Layout, tokens, edge cases.
3. **Then the docs.** `COMPONENTS.md`, validator table, `design_spec.md`.

Do not reverse 1 and 2 — a component that renders something within a minute is a
far stronger demonstration than a perfect one that appears at minute ten.

Do not skip 3. An undocumented component fails spec compliance, and the
documentation discipline is part of what is being assessed.
