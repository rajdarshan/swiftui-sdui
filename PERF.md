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

A single scripted scroll pass to the bottom of the page — after T3, not a
second app launch — produces four more marks:

- **TTI** — the first scroll gesture the app actually processes
  (`onScrollGeometryChange` firing with a changed offset). `ttiMs` = TTI − T0.
  Includes whatever drives the gesture — in the harness, XCUITest's own
  event-injection latency.
- **Per-section build** — `sectionBuildMs`, one entry per content section in
  scroll order (13 for `home_all.json`), plus `fullPageBuildMs`, their sum.
- **Full-page wall time** — `fullPageWallMs`, the last section's first
  commit minus T0. Both screens use `LazyVStack`, so sections past the fold
  don't build until scrolled into view — this metric **necessarily includes
  scroll duration** and is comparable only across runs driven with the same
  scroll cadence, not an absolute render number.
- **Scroll perf** — `scrollFrameCount`, `scrollDroppedFrames`,
  `scrollDroppedPct`, `scrollWorstFrameMs`, `scrollHitchMs`, measured by a
  `CADisplayLink` running for the same TTI-to-last-commit window. A dropped
  frame is one whose actual duration exceeds *its own*
  `targetTimestamp − timestamp` budget by more than 50% — never a fixed
  60Hz assumption, since these are ProMotion, variable-refresh displays.
  These numbers describe the harness's own swipe cadence, not a human's.

**Not measured**: a JSON-fetch/parse-vs-view-build split finer than
`decodeMs`/`buildMs`. Decoding is one `JSONDecoder` pass with node mapping
inside each node's own `init(from:)` — there's no seam to split parse from
map.

`isComplete` is `true` once all four post-T3 marks have landed. The probe's
JSON republishes every time any mark lands (from T3 onward), so
`completedSampleJSON` isn't a one-shot value — wait on `isComplete`, not
merely on the JSON's existence.

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

Marks originate at several call sites and converge on `PerformanceMarks`
(`Performance/PerformanceMarks.swift`), injected via
`@Environment(\.performanceMarks)`:

- T0/T1 — `SDUIRootView.init` / `PageStore.load()`.
- T2 — the top of `SDUIPageView.body` / `StaticHomeView.body`.
- T3 — `FirstCommitProbe`, a shared `UIViewControllerRepresentable` applied
  identically by both screens.
- TTI — both screens' `onScrollGeometryChange` callback, on the first call
  where the offset actually changed.
- Per-section build / last-section commit — `SectionContainer`
  (`Components/SectionContainer.swift`), given a `perfIndex`/
  `perfSectionCount` at each of its 13 content-section call sites in both
  screens. Only the last section pays for a `FirstCommitProbe`.
- Scroll perf — `ScrollJankProbe` (`Performance/ScrollJankProbe.swift`),
  started by `PerformanceMarks.recordTTI` and stopped by
  `recordLastSectionCommit`, so it covers exactly the harness's scroll pass.

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
| `ttiMs` | TTI − T0, in ms; absent until the harness's scroll pass produces a processed gesture |
| `sectionBuildMs` | array of per-section build durations, in scroll order, in ms |
| `fullPageBuildMs` | sum of `sectionBuildMs`, in ms |
| `fullPageWallMs` | last section's first commit − T0, in ms; includes scroll duration |
| `scrollFrameCount`, `scrollDroppedFrames` | frames observed / dropped during the TTI-to-last-commit window |
| `scrollDroppedPct` | `scrollDroppedFrames / scrollFrameCount * 100` |
| `scrollWorstFrameMs`, `scrollHitchMs` | worst single-frame duration and total hitch time over the window, in ms |
| `isComplete` | `true` once TTI, per-section build, last-section commit, and scroll perf have all landed |

## Debugging a failed run

UI tests run on a *cloned* simulator that is destroyed when the run ends,
so `NSLog`/`os_log` output from the app cannot be read back afterwards.
The probe's own label is the diagnostic channel instead: until T3 lands it
publishes `PERF_PENDING enabled=… variant=… t0=… t1=… t2=…`, and the
harness's failure message quotes it. `enabled=false` means
`SDUI_PERF_TRACKING` never reached `PerformanceMarks.make`; a specific
`t*=false` names the mark that was not captured.

Do not apply `.accessibilityElement(children: .ignore)` to the probe
`Text`. It substitutes a fresh accessibility element and discards the
`Text`'s own accessibility content, publishing an empty label — the
harness then finds the element but never sees a payload. The label and
value are set explicitly for this reason.

## Scope note

Per design_spec.md §7: this harness is a local development tool. It is not
gated in CI, and no numeric threshold is enforced — a passing harness run
means the metrics JSON was produced, not that any particular number was
met.
