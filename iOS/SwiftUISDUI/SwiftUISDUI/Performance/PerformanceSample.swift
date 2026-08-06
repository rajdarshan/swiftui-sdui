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

    @MainActor
    init(
        variant: String,
        pageId: String?,
        t0: ContinuousClock.Instant,
        t1: ContinuousClock.Instant,
        t2: ContinuousClock.Instant,
        t3: ContinuousClock.Instant
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
