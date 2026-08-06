//
//  PerformanceProbeOverlay.swift
//  SwiftUISDUI
//
//  Exposes PerformanceMarks.completedSampleJSON to the XCUITest harness via
//  the accessibility tree — the only hand-off mechanism that works
//  identically on Simulator and a real device (no shared container/App
//  Group entitlements exist in this project). Inert (empty string, 1x1pt,
//  effectively invisible) whenever PerformanceMarks is .inactive, i.e.
//  every normal, non-harness launch.
//

import SwiftUI

struct PerformanceProbeOverlay: View {
    @Environment(\.performanceMarks) private var marks

    var body: some View {
        Text(marks.completedSampleJSON ?? "")
            .accessibilityIdentifier("perf.sample.json")
            .accessibilityValue(marks.completedSampleJSON ?? "")
            .frame(width: 1, height: 1)
            .opacity(0.001)
            .allowsHitTesting(false)
    }
}
