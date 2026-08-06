# Performance metrics — static vs SDUI

Real measurements from `ScreenPerformanceHarnessTests`, not a spec or an
estimate. Companion to `PerformanceMetric.md`, which documents the harness
mechanics; this file documents actual numbers from an actual run set.

## Device & methodology

- Device: physical iPhone, model `iPhone14,5`, iOS 26.6.
- Build configuration: **Release**. Debug carries compiler-optimization
  overhead that isn't representative of real performance, so it's excluded
  from the numbers below (a separate one-off Debug run exists at
  `perf-output/iPhone-Debug/` for reference only — not part of this dataset).
- Harness: `iOS/scripts/run-perf-harness.sh 'platform=iOS,id=<device>' Release`,
  which runs `ScreenPerformanceHarnessTests` and exports the JSON each variant
  publishes via its accessibility probe (see `PerformanceMetric.md` for the
  full mechanism).
- **5 runs per variant**, back-to-back, on 2026-08-06, same device session.
  Raw JSON for every run is under `perf-output/runs/run-1` … `run-5`.
- Marks per `design_spec.md` §3.4: T0 (container init) → T1 (decode
  returns) → T2 (body returns) → T3 (first commit, = TTFR), then a single
  scripted scroll pass producing TTI, per-section build time, full-page wall
  time, and scroll-jank stats.
- Scope: one device, one day, five runs. This is a snapshot with visible
  run-to-run spread, not a statistically powered study — the min/max columns
  below exist so the spread isn't hidden behind a single mean.

## Numbers: static vs SDUI (mean, min–max across 5 runs, ms unless noted)

| Metric | Static | SDUI |
|---|---|---|
| `decodeMs` | 0.000 (structural — no decoder on this path) | 19.925 (12.251–37.612) |
| `buildMs` | 0.691 (0.576–1.146) | 3.383 (1.979–7.191) |
| `ttfrMs` (time to first render) | 52.127 (47.501–57.157) | 81.802 (61.559–131.818) |
| `ttiMs` (time to interactive) | 33.137 (29.267–39.634) | 61.040 (44.114–106.825) |
| `fullPageWallMs` | 12710.905 (12625.134–12906.961) | 12828.634 (12755.920–12876.649) |
| `scrollDroppedPct` (%) | 3.393 (3.164–3.825) | 3.485 (2.869–4.270) |
| `scrollHitchMs` | 555.798 (519.318–641.922) | 572.601 (527.982–621.306) |
| `scrollWorstFrameMs` | 109.892 (101.565–127.625) | 114.528 (105.381–121.250) |

`decodeMs` is `0` for static by design, not by measurement — the static
screen has no decoder in its path (`PerformanceMetric.md`).

Run 1's SDUI numbers (`ttfrMs` 131.8, `decodeMs` 37.6) are the visible high
end of the spread — the first test in the session, plausibly a cold-start
effect (first `JSONDecoder` pass, cold caches). It's included, not dropped,
per `PerformanceMetric.md`'s "no threshold gating" scope note — the mean and
range both already reflect it.

## Overhead %

Computed from the means above, SDUI relative to static:

| Metric | Static mean | SDUI mean | Absolute delta | Overhead |
|---|---|---|---|---|
| `ttfrMs` | 52.13ms | 81.80ms | +29.68ms | **+56.9%** |
| `ttiMs` | 33.14ms | 61.04ms | +27.90ms | **+84.2%** |
| `buildMs` | 0.69ms | 3.38ms | +2.69ms | +389.7% (both figures sub-4ms; a large % on a tiny base) |
| `fullPageWallMs` | 12710.91ms | 12828.63ms | +117.73ms | +0.9% |
| `scrollHitchMs` | 555.80ms | 572.60ms | +16.80ms | +3.0% |
| `scrollWorstFrameMs` | 109.89ms | 114.53ms | +4.64ms | +4.2% |
| `scrollDroppedPct` | 3.39pp | 3.49pp | +0.09pp | within run-to-run spread — not a reliable signal at this sample size |

`decodeMs` has no percentage — static's denominator is structurally `0`, not
a small measured value, so a ratio isn't meaningful. Report it as the
absolute cost of decoding instead: ~20ms mean.

`fullPageWallMs` overhead (+0.9%) is small because that metric is dominated
by ~12.7s of scripted scroll time on both variants (`LazyVStack` means
below-the-fold sections build on scroll, not at launch) — per
`PerformanceMetric.md`, it's comparable only across runs with the same
scroll cadence, not a clean framework-cost number. `ttfrMs` and `ttiMs` are
the cleaner signals here because they isolate pre-scroll cost.

## Prove it's fast

Both variants render in well under 150ms even at the high end of the
5-run spread (SDUI's worst `ttfrMs` was 131.8ms; its median across the 5
runs sits closer to 70ms). The SDUI path adds a real, measurable cost —
roughly 20ms of JSON decode plus a few ms of extra body-build work — landing
at **+30ms TTFR / +28ms TTI** on average versus the hardcoded static screen.
In percentage terms that reads as a ~57–84% overhead, but the underlying
absolute numbers are small: this is "SDUI costs ~30ms more than hardcoding
the same screen," not "SDUI is slow." Scroll-phase metrics (dropped-frame %,
hitch time, worst frame) move by low single-digit percentages between
variants — inside the run-to-run noise on this device — meaning the decoder
and registry-driven rendering aren't the source of any scroll jank; both
screens scroll about the same once content is up.

## What was tried, what worked, what didn't

Two separate threads — measurement-infrastructure work and a render-path
design decision. Neither was a reaction to this specific 5-run dataset; both
predate it.

**Harness reliability fixes** (Stage 5 build-out, from git history):
- Main-thread starvation from `PerformanceMarks` republishing its full JSON
  on every mark instead of progressively — fixed by republishing
  incrementally as each mark lands (`3eda5dc`). This was blocking the
  harness itself from completing in reasonable time, not an app slowdown.
- First-write-wins guards added on T0–T3 recording to stop a mark being
  overwritten and corrupting derived metrics.
- An `NSPredicate`/accessibility-label fix so the harness's completion
  check (`isComplete`) could actually match the probe's published value —
  without it the harness timed out waiting on data that was already there.

These fixed whether the *measurement* could be trusted at all — they aren't
render-path optimizations, and none of them changed a number in the tables
above.

**Render-path trade-off — GeometryReader avoidance**: `design_spec.md`
§2.6/§4.1 and `CLAUDE.md`'s Prohibitions establish that item width is
measured **once at the page container** and injected via `@Environment`,
with `GeometryReader` explicitly banned inside any rail, grid cell, or lazy
row. This was a design-time decision (Stage 1/4), not something discovered
by profiling a regression — a `GeometryReader` nested inside a lazily
materialized row recalculates layout on every appearance/every frame, so
that cost was designed out up front rather than measured and removed later.
The trade-off accepted: every rail/grid shares one container-measured width
instead of each item independently sizing itself, in exchange for a fixed,
one-time layout cost instead of a per-frame one.

**Not done**: no render-path optimization has been attempted based on the
numbers in this document. This file is the baseline measurement, not a
before/after optimization report — the ~30ms TTFR/TTI gap above is the
current, unoptimized cost of decode + registry dispatch versus hardcoded
Swift values.
