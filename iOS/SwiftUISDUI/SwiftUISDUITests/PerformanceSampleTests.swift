//
//  PerformanceSampleTests.swift
//  SwiftUISDUITests
//
//  Executed tests for PerformanceSample's derived-metric arithmetic
//  (design_spec.md §3.4: decode = T1-T0, build = T2-T1, TTFR = T3-T0) and
//  DeviceContext's pure, environment-driven branches. Pure logic, no
//  SwiftUI rendering dependency.
//

import Foundation
@testable import SwiftUISDUI
import Testing

@MainActor
struct PerformanceSampleTests {
    private let clock = ContinuousClock()

    @Test
    func decodeMsEqualsT1MinusT0() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let sample = PerformanceSample(variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3)
        #expect(abs(sample.decodeMs - 50) < 0.001)
    }

    @Test
    func buildMsEqualsT2MinusT1() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let sample = PerformanceSample(variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3)
        #expect(abs(sample.buildMs - 30) < 0.001)
    }

    @Test
    func ttfrMsEqualsT3MinusT0() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let sample = PerformanceSample(variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3)
        #expect(abs(sample.ttfrMs - 100) < 0.001)
    }

    @Test
    func staticPathDecodeMsIsZeroWhenT0EqualsT1() {
        let t0t1 = clock.now
        let t2 = t0t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let sample = PerformanceSample(variant: "static", pageId: nil, t0: t0t1, t1: t0t1, t2: t2, t3: t3)
        #expect(sample.decodeMs == 0)
    }

    @Test
    func encodedJSONStringRoundTripsAllFields() throws {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let sample = PerformanceSample(variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3)
        let json = try #require(sample.encodedJSONString())
        let data = try #require(json.data(using: .utf8))
        let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let expectedKeys = [
            "variant", "pageId", "timestamp", "isSimulator", "deviceModel", "osVersion", "buildConfiguration",
            "t1OffsetMs", "t2OffsetMs", "t3OffsetMs", "decodeMs", "buildMs", "ttfrMs"
        ]
        for key in expectedKeys {
            #expect(dict[key] != nil, "missing key \(key)")
        }
    }
}

struct DeviceContextTests {
    @Test
    func isSimulatorTrueWhenSimulatorDeviceNamePresent() {
        #expect(DeviceContext.isSimulator(environment: ["SIMULATOR_DEVICE_NAME": "iPhone 16"]))
    }

    @Test
    func isSimulatorFalseWhenAbsent() {
        #expect(!DeviceContext.isSimulator(environment: [:]))
    }

    @Test
    func deviceModelUsesSimulatorModelIdentifierWhenPresent() {
        let model = DeviceContext.deviceModel(
            simulatorEnvironment: ["SIMULATOR_MODEL_IDENTIFIER": "iPhone17,1"],
            hardwareModelIdentifier: "x86_64"
        )
        #expect(model == "iPhone17,1")
    }

    @Test
    func deviceModelFallsBackToHardwareIdentifierWhenAbsent() {
        let model = DeviceContext.deviceModel(simulatorEnvironment: [:], hardwareModelIdentifier: "iPhone15,2")
        #expect(model == "iPhone15,2")
    }
}
