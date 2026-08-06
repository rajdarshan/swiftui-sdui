//
//  PerformanceMarks.swift
//  SwiftUISDUI
//
//  Assembly point for the T0-T3 marks captured across three separate call
//  sites (PageStore/SDUIRootView for T0/T1, SDUIPageView/StaticHomeView's
//  body for T2, FirstCommitProbe for T3), plus four more marks captured
//  during the single post-load scroll pass (TTI, per-section build,
//  last-section commit, scroll-perf totals — Performance/ScrollJankProbe.swift).
//  Injected via @Environment on the ActionHandler model
//  (Actions/ActionHandler.swift) — always present, no-op by default, so
//  normal app usage pays nothing.
//
//  `completedSampleJSON` is republished every time any mark lands (from T3
//  onward, since a sample can't be assembled before then) rather than once
//  at T3 — the harness waits on `isComplete` in that JSON rather than on
//  the JSON merely existing.
//
//  Gated behind SDUI_LAUNCH_FLOW's sibling launch-environment flag,
//  SDUI_PERF_TRACKING=1: a normal launch never records into
//  ScreenPerformanceTracker or exposes anything via accessibility
//  (design_spec.md §7 excludes field/production metrics collection).
//

import SwiftUI

@Observable
@MainActor
final class PerformanceMarks {
    private let enabled: Bool
    private let variant: String
    private let pageId: String?

    private var t0: ContinuousClock.Instant?
    private var t1: ContinuousClock.Instant?
    private var t2: ContinuousClock.Instant?
    private var t3: ContinuousClock.Instant?
    private var tti: ContinuousClock.Instant?
    private var lastSectionCommit: ContinuousClock.Instant?
    private var sectionBuildMsValues: [Double] = []
    private var scrollStats: ScrollFrameStats?
    private var hasRecordedToTracker = false

    private let scrollProbe = ScrollJankProbe()

    private(set) var completedSampleJSON: String?

    private init(enabled: Bool, variant: String, pageId: String?) {
        self.enabled = enabled
        self.variant = variant
        self.pageId = pageId
    }

    static let inactive = PerformanceMarks(enabled: false, variant: "", pageId: nil)

    static let flagKey = "SDUI_PERF_TRACKING"
    static let enabledValue = "1"

    static func make(from environment: [String: String], variant: String, pageId: String?) -> PerformanceMarks {
        guard environment[flagKey] == enabledValue else { return .inactive }
        return PerformanceMarks(enabled: true, variant: variant, pageId: pageId)
    }

    /// Diagnostic-only view of which marks have landed on *this* instance —
    /// the only channel that survives UI-test simulator cloning, since the
    /// clone (and its NSLog output) is destroyed when the run ends.
    var probeState: String {
        "enabled=\(enabled) variant=\(variant) t0=\(t0 != nil) t1=\(t1 != nil) t2=\(t2 != nil) " +
            "t3=\(t3 != nil) tti=\(tti != nil) lastSectionCommit=\(lastSectionCommit != nil) " +
            "sections=\(sectionBuildMsValues.count) scroll=\(scrollStats != nil)"
    }

    /// First-write-wins: `StaticHomeView`/`SDUIPageView`'s `body` calls this
    /// (via `PageStore.load()`/direct call) unconditionally, and `body`
    /// re-evaluates repeatedly once the harness starts scrolling — without
    /// this guard, T0/T1 drift forward to whatever "now" is by the time
    /// scrolling stops, corrupting every derived metric (`decodeMs`,
    /// `ttfrMs`, `ttiMs`, ...) built from them.
    func recordLoad(t0: ContinuousClock.Instant, t1: ContinuousClock.Instant) {
        guard enabled, self.t0 == nil else { return }
        self.t0 = t0
        self.t1 = t1
    }

    /// First-write-wins for the same reason as `recordLoad`: `body`
    /// re-evaluates on every scroll-driven layout pass, and each call would
    /// otherwise push T2 later, inflating `buildMs` by however long the
    /// scroll pass took.
    func recordT2(_ instant: ContinuousClock.Instant) {
        guard enabled, t2 == nil else { return }
        t2 = instant
    }

    /// First-write-wins as defense in depth — `FirstCommitProbe` already
    /// guarantees a single call via its own `hasFiredCommit` flag, but T0-T3
    /// should not depend on that being the only caller.
    func recordT3(_ instant: ContinuousClock.Instant) {
        guard enabled, t3 == nil else { return }
        t3 = instant
        republish()
    }

    /// First-write-wins: the harness's scripted scroll fires this
    /// repeatedly as the offset changes, but only the first processed
    /// gesture is TTI. Also starts the scroll-perf window (stopped by
    /// `recordLastSectionCommit`).
    func recordTTI(_ instant: ContinuousClock.Instant) {
        guard enabled, tti == nil else { return }
        tti = instant
        scrollProbe.start()
        republish()
    }

    /// First-write-wins per index, like `recordTTI` — `SectionContainer.body`
    /// re-evaluates on every scroll-driven layout pass, and `republish()` is
    /// a synchronous JSON encode; without this guard a long scroll floods
    /// the main thread with redundant encodes and starves the accessibility
    /// queries XCUITest's waiter depends on.
    private var recordedSectionIndices: Set<Int> = []

    func recordSectionBuild(index: Int, durationMs: Double) {
        guard enabled, index >= 0, !recordedSectionIndices.contains(index) else { return }
        recordedSectionIndices.insert(index)
        if sectionBuildMsValues.count <= index {
            sectionBuildMsValues.append(contentsOf: repeatElement(0, count: index - sectionBuildMsValues.count + 1))
        }
        sectionBuildMsValues[index] = durationMs
        republish()
    }

    /// Closes the scroll-perf window opened by `recordTTI` and, with it,
    /// `fullPageWallMs`.
    func recordLastSectionCommit(_ instant: ContinuousClock.Instant) {
        guard enabled, lastSectionCommit == nil else { return }
        lastSectionCommit = instant
        scrollStats = scrollProbe.stop()
        republish()
    }

    private func currentSample() -> PerformanceSample? {
        guard let t0, let t1, let t2, let t3 else { return nil }
        return PerformanceSample(
            variant: variant,
            pageId: pageId,
            t0: t0, t1: t1, t2: t2, t3: t3,
            tti: tti,
            lastSectionCommit: lastSectionCommit,
            sectionBuildMs: sectionBuildMsValues,
            scrollStats: scrollStats
        )
    }

    private func republish() {
        guard let sample = currentSample() else { return }
        completedSampleJSON = sample.encodedJSONString()
        guard sample.isComplete, !hasRecordedToTracker else { return }
        hasRecordedToTracker = true
        Task { await ScreenPerformanceTracker.shared.record(sample) }
    }
}

private struct PerformanceMarksKey: EnvironmentKey {
    static let defaultValue = PerformanceMarks.inactive
}

extension EnvironmentValues {
    var performanceMarks: PerformanceMarks {
        get { self[PerformanceMarksKey.self] }
        set { self[PerformanceMarksKey.self] = newValue }
    }
}
