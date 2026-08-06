//
//  ScreenPerformanceHarnessTests.swift
//  SwiftUISDUIUITests
//
//  Stage 5 perf harness (design_spec.md §3.4, PERF.md). Launches the app
//  directly into a flow via SDUI_LAUNCH_FLOW/SDUI_LAUNCH_PAGE_ID
//  (Screens/LaunchFlow.swift's contract), with SDUI_PERF_TRACKING=1 to
//  activate PerformanceMarks, then reads the completed sample off
//  PerformanceProbeOverlay's accessibility value and attaches it to the
//  test run's .xcresult. Turning that attachment into a bare
//  perf-output/*.json file is iOS/scripts/run-perf-harness.sh's job — not
//  done here, since a direct file write from this process only works on
//  Simulator (unsandboxed), not on a real device.
//
//  After T3, a single scripted scroll pass to the bottom of the page
//  produces the remaining marks (TTI, per-section build, last-section
//  commit, scroll-perf totals — design_spec.md §3.4) — one pass, not a
//  second launch. The harness waits on the sample's `isComplete` flag
//  rather than on `ttfrMs` alone, since the JSON now republishes
//  progressively as each of those marks lands.
//
//  Sanity assertions are structural presence checks only, never numeric
//  thresholds — design_spec.md §7 excludes CI gating on performance
//  thresholds.
//

import XCTest

final class ScreenPerformanceHarnessTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testStaticHomePerformance() throws {
        try runHarness(
            launchEnvironment: ["SDUI_LAUNCH_FLOW": "static", "SDUI_PERF_TRACKING": "1"],
            attachmentName: "static-home-perf.json"
        )
    }

    @MainActor
    func testSDUIHomeAllPerformance() throws {
        try runHarness(
            launchEnvironment: [
                "SDUI_LAUNCH_FLOW": "sdui",
                "SDUI_LAUNCH_PAGE_ID": "home_all",
                "SDUI_PERF_TRACKING": "1"
            ],
            attachmentName: "sdui-home_all-perf.json"
        )
    }

    @MainActor
    private func runHarness(launchEnvironment: [String: String], attachmentName: String) throws {
        let app = XCUIApplication()
        app.launchEnvironment = launchEnvironment
        app.launch()

        let probe = app.descendants(matching: .any).matching(identifier: "perf.sample.json").firstMatch
        guard probe.waitForExistence(timeout: 10) else {
            XCTFail("Element 'perf.sample.json' never appeared. Hierarchy:\n\(app.debugDescription)")
            return
        }

        // Until T3 lands the probe publishes "PERF_PENDING <marks state>" — a
        // failure here reports that state, which names the missing mark.
        let hasSample = NSPredicate(format: "label CONTAINS %@", "ttfrMs")
        let firstSampleExpectation = XCTNSPredicateExpectation(predicate: hasSample, object: probe)
        XCTAssertEqual(
            XCTWaiter().wait(for: [firstSampleExpectation], timeout: 10),
            .completed,
            "perf sample did not land within timeout. Probe label: '\(probe.label)'"
        )

        // One scripted scroll pass to the bottom — this single pass drives
        // TTI, every section's build mark, the last section's commit, and
        // the scroll-perf window (design_spec.md §3.4). Repeated swipes,
        // not one long one, since a page this long doesn't reach bottom in
        // a single gesture.
        for _ in 0..<12 {
            app.swipeUp(velocity: .fast)
        }

        // JSONEncoder's .prettyPrinted output on this toolchain spaces the
        // colon ("isComplete" : true), so match that exactly rather than
        // the more common no-space convention.
        let isComplete = NSPredicate(format: "label CONTAINS %@", "\"isComplete\" : true")
        let completeExpectation = XCTNSPredicateExpectation(predicate: isComplete, object: probe)
        XCTAssertEqual(
            XCTWaiter().wait(for: [completeExpectation], timeout: 15),
            .completed,
            "perf sample never reported isComplete:true after scrolling. Probe label: '\(probe.label)'"
        )

        let json = probe.label
        guard let data = json.data(using: .utf8) else {
            XCTFail("perf sample JSON missing or unreadable")
            return
        }

        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.json")
        attachment.name = attachmentName
        attachment.lifetime = .keepAlways
        add(attachment)

        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(dict?["ttfrMs"] as? Double)
        XCTAssertNotNil(dict?["decodeMs"] as? Double)
        XCTAssertNotNil(dict?["buildMs"] as? Double)
        XCTAssertNotNil(dict?["ttiMs"] as? Double)
        XCTAssertNotNil(dict?["fullPageWallMs"] as? Double)
        XCTAssertNotNil(dict?["sectionBuildMs"] as? [Double])
        XCTAssertNotNil(dict?["fullPageBuildMs"] as? Double)
        XCTAssertNotNil(dict?["scrollFrameCount"] as? Int)
        XCTAssertEqual(dict?["isComplete"] as? Bool, true)
    }
}
