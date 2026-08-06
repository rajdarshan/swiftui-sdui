# Performance harness

Stage 5 measurement layer for comparing static-screen vs SDUI-screen load
performance. Local/dev tool only — not CI-gated, not a production metrics
pipeline (design_spec.md §7).

## What this measures

Four marks (design_spec.md §3.4), captured with `ContinuousClock.Instant`:

- **T0** — page container init.
- **T1** — decoder returns.
- **T2** — body returns.
- **T3** — `CATransaction` completion on first content commit.

Three derived metrics, in milliseconds:

- **decode** = T1 − T0
- **build** = T2 − T1
- **TTFR** (time to first render) = T3 − T0

## Static vs SDUI parity

The static screen has no decoder, so it reports **T0 := T1** — `decodeMs`
is `0` by design. Both variants otherwise produce the same JSON shape
(`variant`, `pageId`, `t1OffsetMs`…`t3OffsetMs`, `decodeMs`, `buildMs`,
`ttfrMs`), so results are directly comparable.

## How marks are captured

Instrumentation is gated behind the `SDUI_PERF_TRACKING=1` launch
environment flag. A normal launch (flag absent) never records into
`ScreenPerformanceTracker` and never exposes anything via accessibility —
this is inert in everyday app usage.

Marks originate at three separate call sites and converge on
`PerformanceMarks` (`Performance/PerformanceMarks.swift`), injected via
`@Environment(\.performanceMarks)`:

- T0/T1 — `SDUIRootView.init` / `PageStore.load()`.
- T2 — the top of `SDUIPageView.body` / `StaticHomeView.body`.
- T3 — `FirstCommitProbe`, a shared `UIViewControllerRepresentable` applied
  identically by both screens.

## Running the harness

```
iOS/scripts/run-perf-harness.sh 'platform=iOS Simulator,name=iPhone 16' Debug
iOS/scripts/run-perf-harness.sh 'platform=iOS,id=<device-udid>' Release
```

The first argument is any valid `xcodebuild -destination` value (Simulator
or a real, USB/network-connected device). The second is the build
configuration (`Debug` or `Release`), defaulting to `Debug`.

Real-device Release runs additionally require the device to already be
trusted/paired with Xcode and covered by a valid provisioning profile for
`com.rajdarshan.SwiftUISDUI`/`com.rajdarshan.SwiftUISDUIUITests` — that's
local signing/environment setup this script can't do for you.

## Where the output lands

`perf-output/*.json` at the repo root (already gitignored, regenerated
each run). The harness (`ScreenPerformanceHarnessTests`) doesn't write this
file directly — it launches the app, reads the completed sample off an
accessibility probe, and attaches it to the test run's `.xcresult`. The
script then runs `xcrun xcresulttool export attachments` and copies the
matching files out to `perf-output/`. This indirection is what makes the
harness work identically on Simulator and a real device: a direct file
write from the test process only works on Simulator, since Simulator
processes aren't sandboxed the way on-device apps are.

## Reading the JSON

| Field | Meaning |
|---|---|
| `variant` | `"static"` or `"sdui"` |
| `pageId` | SDUI page id, `null` for static |
| `timestamp` | ISO 8601 wall-clock capture time — metadata for tagging/comparing runs, not part of the T0–T3 measurement |
| `isSimulator` | whether this run was on Simulator or a real device |
| `deviceModel` | hardware identifier (e.g. `iPhone15,2`) or Simulator model identifier |
| `osVersion` | `UIDevice.current.systemVersion` |
| `buildConfiguration` | `"Debug"` or `"Release"` |
| `t1OffsetMs`…`t3OffsetMs` | each mark's offset from T0, in ms |
| `decodeMs`, `buildMs`, `ttfrMs` | derived metrics, in ms |

## Known issues

`ScreenPerformanceHarnessTests` currently fails: the perf sample never
lands within the harness's wait window when the app is launched via
`XCUIApplication`, even though the exact same launch-environment flags,
launched directly via `xcrun simctl launch`, complete the full T0–T3
pipeline in well under a second. The `SDUI_PERF_TRACKING` flag has been
confirmed to reach the app process correctly in both cases. Root cause is
still under investigation — the difference appears specific to something
about XCUITest's launch/accessibility-observation path rather than the
marks-capture logic itself. Not yet resolved.

## Scope note

Per design_spec.md §7: this harness is a local development tool. It is not
gated in CI, and no numeric threshold is enforced — a passing harness run
means the metrics JSON was produced, not that any particular number was
met.
