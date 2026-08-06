# AI collaboration workflow

How Claude Code was actually used to build this repository — not a general
AI-workflow guide. Every claim below traces to a real file, commit, or
session in this project.

## Workflow

`CLAUDE.md` defines a fixed loop per unit of work: **plan → test →
implement → verify → commit → spec-compliance → human review gate**, and
explicitly forbids proceeding past that gate without instruction. Two
documents split authority and are never re-derived from memory:
`design_spec.md` owns design values, architecture, and SwiftUI decisions;
`COMPONENTS.md` owns the JSON schema contract. `CLAUDE.md`'s cardinal rule —
"do not invent, infer, or fill gaps... stop and ask" — is the thing every
other habit in this document is downstream of.

## TDD in practice

Git history shows test commits as their own logical increments, not
folded into feature commits: `c54c68c test(ios): correct ItemWidth test
margin literals`, `4de1ab4 test(ios): cover PerformanceSample derived-metric
arithmetic`, `47a7859 test(ios): cover full decode of the fallback demo
payload`. `CLAUDE.md` draws a hard line between two kinds of verification:
**executed tests** (pure logic — decoder, fallback resolution, token/width
math — run with Swift Testing, not XCTest) and **compile-only
verification** (SwiftUI views, which compile but don't run in CI). The rule
stated plainly: "a passing build is not a passing test" — reports have to
say which kind of verification actually happened.

## spec-compliance subagent

`.claude/agents/spec-compliance.md` defines a read-only auditor
(`Read`/`Grep`/`Glob` only — no edits, no builds, no test runs), invoked
after every unit of work and at the end of every stage. Its checklist has
9 categories (scope, design values, architecture, SwiftUI prohibitions,
schema conformance, versioning, fallback rules, verification honesty,
commit format), and the rule for reporting a violation is strict: cite the
governing spec section *and* the file:line, or don't assert it. Ambiguous,
spec-silent cases are reported as "Concerns" for the human to resolve —
the agent is explicitly told not to decide them itself. Output is one of
`PASS` / `PASS WITH FINDINGS` / `FAIL`.

## Sharp briefs

The clearest instructions in this project's history were the ones that
removed a decision rather than left one implicit: "run the harness 5 times,
Release configuration, on this device UDID" produced a plan step with
nothing left to interpret. The alternative — a request that implies a
number or a scope without stating it — is exactly what `CLAUDE.md`'s
"stop and ask" rule exists to catch before an assumption becomes an
invented fact in a document. In practice that showed up as pushback mid-
plan more than once this session: computing a real number from evidence,
then checking it against what was asked for rather than silently
overwriting one with the other.

## Rejected outputs

Two real cases where an approach was tried and then specifically rejected —
kept distinct because they're different *kinds* of rejection:

1. **A design assumption, rejected once real-device sandboxing was
   understood.** The Stage 5 perf-harness plan initially assumed
   `ScreenPerformanceHarnessTests` could write its JSON straight to
   `perf-output/` at the repo root via `FileManager`, relying on the
   Simulator's unsandboxed filesystem. That assumption doesn't hold on a
   real device — iOS sandboxes the UI-test-runner process, so the same code
   would work on Simulator and silently produce nothing on a physical
   phone. It was replaced with `XCTAttachment`-into-`.xcresult`, the one
   hand-off mechanism `xcodebuild test` guarantees identically on both
   destinations, plus a wrapper script (`iOS/scripts/run-perf-harness.sh`)
   that extracts it afterward — this reasoning is preserved directly in
   that script's header comment.
2. **A pattern rejected before it was ever written.** Scroll-offset
   tracking for the collapsing header is the one place a
   `GeometryReader`+`PreferenceKey` combination is the "obvious" default —
   it's the pattern most SwiftUI tutorials reach for first. `design_spec.md`
   §4.2 and `CLAUDE.md`'s Prohibitions rule it out explicitly in favor of
   iOS 18's `onGeometryChange`, measured once at the page container
   (`AvailableWidth.swift`) and injected via `@Environment`. Named honestly:
   this is a pattern blocked at spec-time by an explicit written
   prohibition, not a case of writing the `GeometryReader` version first and
   reverting it — no such commit exists in this repo's history.

## A credible failure story

Stage 5's perf harness started failing with "Timed out while evaluating UI
query." The first hypothesis was Simulator boot corruption — BackBoard
stuck in a terminal error state, a real and verified symptom — but it was a
red herring; resetting the simulator didn't fix anything. The actual root
cause: `SectionContainer.body` re-evaluates on every scroll-driven layout
pass, and each re-evaluation called `republish()`, which synchronously
JSON-encoded the full performance sample onto the main thread. Redundant
encodes flooded the main thread and starved the accessibility queries
XCUITest needs to read results back. Fixed with a first-write-wins guard —
a `Set<Int>` of already-recorded section indices. That fix immediately
surfaced a *second* bug: the harness's `XCTWaiter` still timed out even
though `completedSampleJSON` already contained `isComplete:true` — traced
to an `NSPredicate` matching the literal string `"isComplete":true` while
`JSONEncoder.prettyPrinted` actually emits `"isComplete" : true`, with
spaces around the colon. Fixing that string finally got the harness passing
end to end. Two fixes, not one, and the first hypothesis was wrong.

A second, smaller one: after `resolveItemWidth` was simplified, five
`ItemWidth` tests failed by an oddly precise, identical offset —
4.923pt on every size variant. That number was the diagnostic: it's exactly
`16/3.25`, meaning the formula was subtracting one page margin instead of
two. But the refactor hadn't introduced the bug — an earlier commit had
already changed `Spacing.pageMargin` from 16 to 8 without updating
`design_spec.md` §2.3 or the test literals, and the refactor just exposed a
stale spec/test mismatch that predated it. Fixed by updating both the spec
value and the test literals to the current constant, verified by the full
suite and a clean swiftlint pass.

## Verification habits

`.husky/pre-commit` runs `swiftlint --strict` and SDUI payload validation
on every commit, mechanically — not left to review discipline.
`PerformanceMetric.md` is explicit that harness output carries "no numeric
threshold enforced" and is not CI-gated: a passing run means the metric
JSON was produced, not that any particular number was hit. The same
standard applied from the measurement side in this project's own `PERF.md`
work — an initial 2-run dataset (1 Debug, 1 Release) was not relabeled as
5 runs to match a requested sample size; 5 fresh Release-configuration runs were
executed on-device instead, and the resulting numbers — spread, outliers,
and all — are what the document reports.
