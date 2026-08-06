//
//  PerformanceProbeOverlay.swift
//  SwiftUISDUI
//
//  Exposes PerformanceMarks.completedSampleJSON to the XCUITest harness via
//  the accessibility tree — the only hand-off mechanism that works
//  identically on Simulator and a real device (no shared container/App
//  Group entitlements exist in this project). Inert (a pending marker,
//  effectively invisible) whenever PerformanceMarks is .inactive, i.e.
//  every normal, non-harness launch.
//
//  The label is published explicitly rather than left to Text's intrinsic
//  accessibility content: an earlier .accessibilityElement(children:
//  .ignore) here substituted a fresh element and discarded the Text's own
//  content, so the harness only ever saw an empty label. Do not reintroduce
//  it. The pending marker carries marks.probeState because UI tests run on
//  a cloned simulator that is destroyed on completion — NSLog cannot be
//  read back, so this label is the only diagnostic channel that survives.
//

import SwiftUI

struct PerformanceProbeOverlay: View {
    @Environment(\.performanceMarks) private var marks

    var body: some View {
        let payload = marks.completedSampleJSON ?? "PERF_PENDING \(marks.probeState)"
        Text(payload)
            .accessibilityIdentifier("perf.sample.json")
            .accessibilityLabel(payload)
            .accessibilityValue(payload)
            .opacity(0.001)
            .allowsHitTesting(false)
    }
}
