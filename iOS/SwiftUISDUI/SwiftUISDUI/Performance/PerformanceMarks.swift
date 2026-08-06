//
//  PerformanceMarks.swift
//  SwiftUISDUI
//
//  Assembly point for the T0-T3 marks captured across three separate call
//  sites (PageStore/SDUIRootView for T0/T1, SDUIPageView/StaticHomeView's
//  body for T2, FirstCommitProbe for T3). Injected via @Environment on the
//  ActionHandler model (Actions/ActionHandler.swift) — always present,
//  no-op by default, so normal app usage pays nothing.
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

    /// Diagnostic-only view of which marks have landed on *this* instance.
    var probeState: String {
        "enabled=\(enabled) variant=\(variant) t0=\(t0 != nil) t1=\(t1 != nil) t2=\(t2 != nil)"
    }

    func recordLoad(t0: ContinuousClock.Instant, t1: ContinuousClock.Instant) {
        guard enabled else { return }
        self.t0 = t0
        self.t1 = t1
    }

    func recordT2(_ instant: ContinuousClock.Instant) {
        guard enabled else { return }
        t2 = instant
    }

    func recordT3(_ instant: ContinuousClock.Instant) {
        guard enabled, let t0, let t1, let t2 else { return }
        let sample = PerformanceSample(variant: variant, pageId: pageId, t0: t0, t1: t1, t2: t2, t3: instant)
        Task { await ScreenPerformanceTracker.shared.record(sample) }
        completedSampleJSON = sample.encodedJSONString()
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
