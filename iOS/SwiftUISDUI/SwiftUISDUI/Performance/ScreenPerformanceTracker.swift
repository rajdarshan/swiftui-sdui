//
//  ScreenPerformanceTracker.swift
//  SwiftUISDUI
//
//  design_spec.md §3.1: standalone actor, instrumented from both variants.
//  In-process ledger of completed samples; the natural future home for
//  optional Supabase dashboarding (§3.4, out of scope for now).
//

actor ScreenPerformanceTracker {
    static let shared = ScreenPerformanceTracker()

    private(set) var samples: [PerformanceSample] = []

    func record(_ sample: PerformanceSample) {
        samples.append(sample)
    }
}
