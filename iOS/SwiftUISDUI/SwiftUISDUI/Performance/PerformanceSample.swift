//
//  PerformanceSample.swift
//  SwiftUISDUI
//
//  design_spec.md §3.4: T0 page container init, T1 decoder returns, T2 body
//  returns, T3 CATransaction completion on first content commit. Derived:
//  decode = T1-T0, build = T2-T1, TTFR = T3-T0. Offsets/derived metrics use
//  ContinuousClock exclusively (monotonic, per §3.4); timestamp/device/OS/
//  build-config fields below are wall-clock metadata for tagging and
//  comparing runs, not part of that measurement.
//
//  T3 is followed by a single harness-driven scroll pass to the bottom of
//  the page, which produces four more marks, all optional because they can
//  only be known once that pass completes: TTI (first processed scroll),
//  per-section build durations, the last section's first commit (closes
//  fullPageWallMs), and scroll-perf totals over that same pass
//  (Performance/ScrollJankProbe.swift). `isComplete` is true once all of
//  them have landed. fullPageWallMs necessarily includes scroll duration —
//  it is not a pure render metric — and the scroll-perf numbers describe
//  the harness's own swipe cadence, not a human's; both are comparable only
//  across runs driven identically.
//

import Foundation
import UIKit

struct PerformanceSample: Codable, Equatable, Sendable {
    let variant: String
    let pageId: String?
    let timestamp: String
    let isSimulator: Bool
    let deviceModel: String
    let osVersion: String
    let buildConfiguration: String
    let t1OffsetMs: Double
    let t2OffsetMs: Double
    let t3OffsetMs: Double
    let decodeMs: Double
    let buildMs: Double
    let ttfrMs: Double
    let ttiMs: Double?
    let fullPageWallMs: Double?
    let sectionBuildMs: [Double]
    let fullPageBuildMs: Double?
    let scrollFrameCount: Int?
    let scrollDroppedFrames: Int?
    let scrollDroppedPct: Double?
    let scrollWorstFrameMs: Double?
    let scrollHitchMs: Double?
    let isComplete: Bool

    @MainActor
    init(
        variant: String,
        pageId: String?,
        t0: ContinuousClock.Instant,
        t1: ContinuousClock.Instant,
        t2: ContinuousClock.Instant,
        t3: ContinuousClock.Instant
    ) {
        self.init(
            variant: variant, pageId: pageId, t0: t0, t1: t1, t2: t2, t3: t3,
            tti: nil, lastSectionCommit: nil, sectionBuildMs: [], scrollStats: nil
        )
    }

    @MainActor
    init(
        variant: String,
        pageId: String?,
        t0: ContinuousClock.Instant,
        t1: ContinuousClock.Instant,
        t2: ContinuousClock.Instant,
        t3: ContinuousClock.Instant,
        tti: ContinuousClock.Instant?,
        lastSectionCommit: ContinuousClock.Instant?,
        sectionBuildMs: [Double],
        scrollStats: ScrollFrameStats?
    ) {
        self.variant = variant
        self.pageId = pageId
        let context = DeviceContext.current()
        timestamp = context.timestamp
        isSimulator = context.isSimulator
        deviceModel = context.deviceModel
        osVersion = context.osVersion
        buildConfiguration = context.buildConfiguration
        t1OffsetMs = (t1 - t0).milliseconds
        t2OffsetMs = (t2 - t0).milliseconds
        t3OffsetMs = (t3 - t0).milliseconds
        decodeMs = (t1 - t0).milliseconds
        buildMs = (t2 - t1).milliseconds
        ttfrMs = (t3 - t0).milliseconds
        ttiMs = tti.map { ($0 - t0).milliseconds }
        fullPageWallMs = lastSectionCommit.map { ($0 - t0).milliseconds }
        self.sectionBuildMs = sectionBuildMs
        fullPageBuildMs = sectionBuildMs.isEmpty ? nil : sectionBuildMs.reduce(0, +)
        scrollFrameCount = scrollStats?.frameCount
        scrollDroppedFrames = scrollStats?.droppedFrames
        scrollDroppedPct = scrollStats.flatMap { stats in
            stats.frameCount > 0 ? (Double(stats.droppedFrames) / Double(stats.frameCount)) * 100 : nil
        }
        scrollWorstFrameMs = scrollStats?.worstFrameMs
        scrollHitchMs = scrollStats?.hitchMs
        isComplete = tti != nil && lastSectionCommit != nil && scrollStats != nil
    }
}

extension PerformanceSample {
    func encodedJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension Duration {
    var milliseconds: Double {
        let (seconds, attoseconds) = components
        return Double(seconds) * 1000 + Double(attoseconds) / 1_000_000_000_000_000
    }
}

struct DeviceContext: Equatable, Sendable {
    let timestamp: String
    let isSimulator: Bool
    let deviceModel: String
    let osVersion: String
    let buildConfiguration: String

    static func isSimulator(environment: [String: String]) -> Bool {
        environment["SIMULATOR_DEVICE_NAME"] != nil
    }

    static func deviceModel(simulatorEnvironment environment: [String: String], hardwareModelIdentifier: String) -> String {
        environment["SIMULATOR_MODEL_IDENTIFIER"] ?? hardwareModelIdentifier
    }

    @MainActor
    static func current() -> DeviceContext {
        let environment = ProcessInfo.processInfo.environment
        #if DEBUG
        let buildConfiguration = "Debug"
        #else
        let buildConfiguration = "Release"
        #endif
        return DeviceContext(
            timestamp: ISO8601DateFormatter().string(from: Date()),
            isSimulator: isSimulator(environment: environment),
            deviceModel: deviceModel(simulatorEnvironment: environment, hardwareModelIdentifier: hardwareModelIdentifier()),
            osVersion: UIDevice.current.systemVersion,
            buildConfiguration: buildConfiguration
        )
    }

    private static func hardwareModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
        }
    }
}
