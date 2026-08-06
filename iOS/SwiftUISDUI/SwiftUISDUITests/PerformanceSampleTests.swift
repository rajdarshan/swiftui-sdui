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

    @Test
    func scrollWindowFieldsOmittedWhenAbsent() throws {
        // design_spec.md §3.4: the T0-T3-only init (still used until the
        // scroll pass completes) must not publish the later fields at all.
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let sample = PerformanceSample(variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3)
        #expect(sample.ttiMs == nil)
        #expect(sample.fullPageWallMs == nil)
        #expect(sample.fullPageBuildMs == nil)
        #expect(sample.sectionBuildMs.isEmpty)
        #expect(sample.scrollFrameCount == nil)
        #expect(!sample.isComplete)

        let json = try #require(sample.encodedJSONString())
        let data = try #require(json.data(using: .utf8))
        let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        for key in ["ttiMs", "fullPageWallMs", "fullPageBuildMs", "scrollFrameCount", "scrollDroppedPct"] {
            #expect(dict[key] == nil, "expected key \(key) to be omitted when absent")
        }
    }

    @Test
    func ttiMsEqualsTtiMinusT0WhenPresent() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let tti = t3.advanced(by: .milliseconds(200))
        let sample = PerformanceSample(
            variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3,
            tti: tti, lastSectionCommit: nil, sectionBuildMs: [], scrollStats: nil
        )
        #expect(abs((sample.ttiMs ?? -1) - 300) < 0.001)
    }

    @Test
    func fullPageWallMsEqualsLastSectionCommitMinusT0() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let lastCommit = t3.advanced(by: .milliseconds(500))
        let sample = PerformanceSample(
            variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3,
            tti: nil, lastSectionCommit: lastCommit, sectionBuildMs: [], scrollStats: nil
        )
        #expect(abs((sample.fullPageWallMs ?? -1) - 600) < 0.001)
    }

    @Test
    func fullPageBuildMsIsSumOfSectionBuildMs() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let sample = PerformanceSample(
            variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3,
            tti: nil, lastSectionCommit: nil, sectionBuildMs: [1.5, 2.5, 3.0], scrollStats: nil
        )
        #expect(abs((sample.fullPageBuildMs ?? -1) - 7.0) < 0.001)
    }

    @Test
    func scrollDroppedPctComputedFromStats() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let stats = ScrollFrameStats(frameCount: 200, droppedFrames: 10, worstFrameMs: 42, hitchMs: 100)
        let sample = PerformanceSample(
            variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3,
            tti: nil, lastSectionCommit: nil, sectionBuildMs: [], scrollStats: stats
        )
        #expect(sample.scrollFrameCount == 200)
        #expect(sample.scrollDroppedFrames == 10)
        #expect(abs((sample.scrollDroppedPct ?? -1) - 5.0) < 0.001)
        #expect(sample.scrollWorstFrameMs == 42)
        #expect(sample.scrollHitchMs == 100)
    }

    @Test
    func scrollDroppedPctNilWhenFrameCountIsZero() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let stats = ScrollFrameStats(frameCount: 0, droppedFrames: 0, worstFrameMs: 0, hitchMs: 0)
        let sample = PerformanceSample(
            variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3,
            tti: nil, lastSectionCommit: nil, sectionBuildMs: [], scrollStats: stats
        )
        #expect(sample.scrollDroppedPct == nil)
    }

    @Test
    func isCompleteTrueOnlyWhenAllFourLaterMarksPresent() {
        let t0 = clock.now
        let t1 = t0.advanced(by: .milliseconds(50))
        let t2 = t1.advanced(by: .milliseconds(30))
        let t3 = t2.advanced(by: .milliseconds(20))
        let tti = t3.advanced(by: .milliseconds(100))
        let lastCommit = tti.advanced(by: .milliseconds(400))
        let stats = ScrollFrameStats(frameCount: 60, droppedFrames: 0, worstFrameMs: 16.7, hitchMs: 0)

        let complete = PerformanceSample(
            variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3,
            tti: tti, lastSectionCommit: lastCommit, sectionBuildMs: [1, 2], scrollStats: stats
        )
        #expect(complete.isComplete)

        let missingScroll = PerformanceSample(
            variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3,
            tti: tti, lastSectionCommit: lastCommit, sectionBuildMs: [1, 2], scrollStats: nil
        )
        #expect(!missingScroll.isComplete)

        let missingTTI = PerformanceSample(
            variant: "sdui", pageId: "home_all", t0: t0, t1: t1, t2: t2, t3: t3,
            tti: nil, lastSectionCommit: lastCommit, sectionBuildMs: [1, 2], scrollStats: stats
        )
        #expect(!missingTTI.isComplete)
    }
}

struct ScrollFrameAccumulatorTests {
    @Test
    func framesWithinBudgetAreNotDropped() {
        var totals = ScrollFrameAccumulator.Totals()
        // ProMotion 120Hz budget is ~8.33ms; a frame landing right on
        // budget must not count as dropped.
        ScrollFrameAccumulator.accumulate(expectedMs: 8.33, actualMs: 8.33, into: &totals)
        #expect(totals.droppedFrames == 0)
        #expect(totals.hitchMs == 0)
    }

    @Test
    func frameOverOneAndHalfBudgetCountsAsDropped() {
        var totals = ScrollFrameAccumulator.Totals()
        ScrollFrameAccumulator.accumulate(expectedMs: 8.33, actualMs: 25, into: &totals)
        #expect(totals.droppedFrames > 0)
        #expect(totals.hitchMs > 0)
    }

    @Test
    func worstFrameMsTracksMaximumAcrossCalls() {
        var totals = ScrollFrameAccumulator.Totals()
        ScrollFrameAccumulator.accumulate(expectedMs: 16.7, actualMs: 16.7, into: &totals)
        ScrollFrameAccumulator.accumulate(expectedMs: 16.7, actualMs: 50, into: &totals)
        ScrollFrameAccumulator.accumulate(expectedMs: 16.7, actualMs: 20, into: &totals)
        #expect(totals.worstFrameMs == 50)
    }

    @Test
    func hitchMsAccumulatesAcrossMultipleDroppedFrames() {
        var totals = ScrollFrameAccumulator.Totals()
        ScrollFrameAccumulator.accumulate(expectedMs: 16.7, actualMs: 40, into: &totals)
        ScrollFrameAccumulator.accumulate(expectedMs: 16.7, actualMs: 40, into: &totals)
        #expect(abs(totals.hitchMs - ((40 - 16.7) * 2)) < 0.001)
    }

    @Test
    func zeroExpectedBudgetIsIgnored() {
        var totals = ScrollFrameAccumulator.Totals()
        ScrollFrameAccumulator.accumulate(expectedMs: 0, actualMs: 40, into: &totals)
        #expect(totals.droppedFrames == 0)
        #expect(totals.worstFrameMs == 0)
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
