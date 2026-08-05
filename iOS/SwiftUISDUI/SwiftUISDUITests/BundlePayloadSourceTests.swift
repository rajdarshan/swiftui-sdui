//
//  BundlePayloadSourceTests.swift
//  SwiftUISDUITests
//
//  Executed tests for BundlePayloadSource (design_spec.md §3.1). This target
//  is a hosted unit test bundle (TEST_HOST in project.pbxproj) that runs
//  inside the SwiftUISDUI.app process, so `Bundle.main` here is the real app
//  bundle carrying Resources/Payloads — no fixture bundle or mock needed.
//

@testable import SwiftUISDUI
import Testing

struct BundlePayloadSourceTests {
    private let source = BundlePayloadSource()

    @Test
    func loadsManifestWithAllEightPageIds() async throws {
        let manifest = try await source.loadManifest()
        let pageIds = Set(manifest.payloads.map(\.pageId))
        #expect(pageIds == [
            "home_all", "home_buy_used_car", "home_sell_car", "home_loans",
            "home_challan", "home_car_check", "home_insurance", "home_all_fallback_demo"
        ])
    }

    @Test
    func loadsHomeAllByPageId() async throws {
        let envelope = try await source.loadPage(pageId: "home_all")
        #expect(envelope.pageId == "home_all")
        #expect(envelope.sections.count == 14)
    }

    @Test(
        "Loads each of the six stub pages",
        arguments: ["home_buy_used_car", "home_sell_car", "home_loans", "home_challan", "home_car_check", "home_insurance"]
    )
    func loadsStubPage(pageId: String) async throws {
        let envelope = try await source.loadPage(pageId: pageId)
        #expect(envelope.pageId == pageId)
    }

    @Test
    func loadsFallbackDemoPayload() async throws {
        let envelope = try await source.loadPage(pageId: "home_all_fallback_demo")
        #expect(envelope.pageId == "home_all_fallback_demo")
    }

    @Test
    func unknownPageIdThrows() async {
        await #expect(throws: PayloadSourceError.self) {
            try await source.loadPage(pageId: "does_not_exist")
        }
    }
}
