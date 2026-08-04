# CLAUDE.md

Working agreement for this repository. Read `design_spec.md` and `COMPONENTS.md`
before writing any code.

---

## Source of truth

| File | Authority over |
|---|---|
| `design_spec.md` | Design values, architecture, SwiftUI implementation decisions, screen composition, scope boundaries |
| `COMPONENTS.md` | JSON schema contract, token names, node shapes, fallback rules |
| `CLAUDE.md` | Workflow, commands, commit conventions |
| `ADDING_A_COMPONENT.md` | Runbook for extending the system — read it before adding any component, prop, container, token or action |

**Do not invent, infer, or fill gaps.** If a detail is not specified in these
files, stop and ask. Do not resolve ambiguity from general knowledge, from other
source material, or from what seems reasonable. An unasked question that turns
into an invented decision is the primary failure mode here.

Do not re-derive decisions already recorded. `design_spec.md` §4 lists SwiftUI
choices with rationale. Implement them; do not re-evaluate them.

---

## Repository

```
swiftui-sdui/
├── .github/workflows/
│   ├── ios-build.yml
│   └── sdui-release.yml
├── iOS/
│   ├── SwiftUISDUI.xcodeproj  # created manually — never generate or modify project structure
│   ├── SwiftUISDUI/           # app sources
│   ├── SwiftUISDUITests/      # executed unit tests
│   └── SwiftUISDUIUITests/    # perf harness (stage 5)
├── sdui-config/
│   ├── config.json
│   ├── payloads/
│   ├── .versionrc.json
│   ├── CHANGELOG.md
│   └── package.json
├── .husky/
├── .claude/agents/spec-compliance.md
├── reference/                 # gitignored — local screenshots, never committed
└── package.json
```

The Xcode project is created and configured manually. Claude adds source files;
Claude does not create targets, schemes, or build settings.

---

## Commands

**Build (primary verification):**
```
xcodebuild -project iOS/SwiftUISDUI.xcodeproj -scheme SwiftUISDUI -configuration Debug clean build | xcbeautify
```

**Test (pure logic only):**
```
xcodebuild test -project iOS/SwiftUISDUI.xcodeproj -scheme SwiftUISDUI -destination 'platform=iOS Simulator,name=iPhone 16' | xcbeautify
```

**Lint:**
```
swiftlint
jq -e . sdui-config/payloads/*.json
```

All build and test output must be piped through `xcbeautify`.

---

## Verification model

This project uses TDD adapted to a compile-first loop. The distinction matters:

**Executed tests** — pure logic with no SwiftUI dependency: decoder, fallback
resolution, registry lookup, token resolution, item-width arithmetic, payload
validation. Written first, run with `xcodebuild test`, must pass.

**Compile-only verification** — SwiftUI views and anything requiring a rendered
hierarchy. Tests are written and must compile, but are not executed during
development stages.

**A passing build is not a passing test.** Never report view code as "verified"
or "working" on the basis of a clean build. State plainly which of the two
applies to the work being reported.

The performance harness is stage 5. Do not write performance measurement code
before both screens are complete.

---

## Development workflow

Per unit of work, in order:

1. **Plan** — state what will change and which spec sections govern it.
2. **Test** — write the test first. Executed or compile-only per the model above.
3. **Implement** — smallest change that satisfies the spec.
4. **Verify** — run build; run tests if the unit has executed tests.
5. **Commit** — one logical increment, conventional commit format.
6. **Spec-compliance** — the `spec-compliance` subagent audits the change.
7. **Stop.** The human reviews and runs the build before the next unit.

Do not proceed past step 7 without explicit instruction.

---

## Stages

Each stage ends with a spec-compliance run and a human review gate.

| # | Stage | Done when |
|---|---|---|
| 0 | Tooling — husky, commitlint, swiftlint config, jq lint, `.versionrc.json` | Hooks fire on commit |
| 1 | Design system — `Palette`, `Typography`, `Spacing`, `Radius`, `IconToken`, width resolver | Builds; width resolver unit tests pass |
| 2 | Leaf components + static screen, full 14-section parity | **Launches in simulator and is visually reviewed** |
| 3 | Node models, decoder, fallback resolution | Decoder + fallback unit tests pass |
| 4 | Registry, `PageStore`, `SDUIPageView`, `ActionHandler`, `DebugActionScreen` | SDUI screen renders `home_all.json`; fallback demo payload behaves per spec |
| 5 | `ScreenPerformanceTracker`, XCUITest harness, `PERF.md` | Harness produces a metrics JSON |
| 6 | Supabase `PayloadSource`, GitHub Actions | Payload change reaches the app after relaunch |

**Stage 2 is a hard gate.** The static screen must launch and be visually
approved before any SDUI work begins.

---

## Commits

Conventional commits. `commitlint` enforced via husky.

Types: `feat` `fix` `refactor` `test` `docs` `chore` `perf` `build` `ci`

Scopes: standard, plus `ios` · `sdui-config` · `perf` · `docs`

```
feat(ios): add carCard leaf view with spec chip row
test(ios): cover decoder fallback resolution for unknown item types
chore(sdui-config): add fallback demo payload
```

One logical increment per commit. Do not batch unrelated changes.

---

## Prohibitions

Architecture:
- No `ObservableObject` or `@Observable` per node. Nodes are structs.
- No Swift `enum` for the component registry. String-keyed dictionary only.
- No closures inside node models. Actions are data.
- No third-party architecture dependency (TCA, Redux, RxSwift).
- Leaf views never receive a JSON node or the registry.

SwiftUI:
- No `AsyncImage`. Use the cached loader.
- No `GeometryReader` + `PreferenceKey` scroll-offset tracking. Use
  `onScrollGeometryChange`.
- No `GeometryReader` inside a rail, grid cell, or lazy row.
- No `TabView(.page)` for the value-prop carousel. Permitted only for the
  `placeCard` image pager.
- No `LazyVGrid` for the fixed 3x2 grids.
- No index-based `ForEach`. Always `id: \.id`.

Versioning (`COMPONENTS.md` §2):
- `schemaVersion` is `major.minor` and describes the **contract**. `version` is
  semver and describes the **content**. Never conflate them.
- Any schema change requires, in the same commit: the contract edit in
  `COMPONENTS.md`, a row in its §14 history, and an update to the `SINCE` table
  in `scripts/validate-payloads.mjs`.
- A payload declares the lowest version that can render it. Do not raise a
  payload's `schemaVersion` unless it actually uses a newer feature.
- Never bump `version` by hand — `standard-version` owns it.
- The client must not gate rendering on `schemaVersion`.

Repository hygiene:
- Never commit anything from `reference/`, and never copy an image out of it
  into the repo, the README, or an asset catalogue. It is local-only.
- Never add a real company name, product name, or named individual to payload
  sample data, documentation, or code.

Payloads:
- No `null` values. Omit absent keys.
- No emoji literals. Icons are tokens.
- No raw hex or point values. Tokens only.
- Item `id` must be unique page-scoped.

Scope:
- Do not build anything listed in `design_spec.md` §7.
- Do not add components not in `COMPONENTS.md` §7 without asking first.

---

## Reporting

When reporting completed work, state:
- Which spec sections govern the change
- Which tests are executed vs compile-only
- Anything that could not be implemented as specified, and why

Do not describe unverified behaviour as working. Do not claim visual fidelity
without a simulator screenshot reviewed by the human.
