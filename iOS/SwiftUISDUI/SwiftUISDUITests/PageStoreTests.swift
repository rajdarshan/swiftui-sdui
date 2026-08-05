//
//  PageStoreTests.swift
//  SwiftUISDUITests
//
//  Executed tests for PageStore (design_spec.md §3.1). No SwiftUI
//  dependency — @Observable/@MainActor state plus a stub PayloadSource.
//

import Foundation
@testable import SwiftUISDUI
import Testing

private struct StubError: Error {}

private nonisolated struct StubPayloadSource: PayloadSource {
    let pageResult: Result<PageEnvelope, Error>

    func loadManifest() async throws -> Manifest {
        Manifest(manifestVersion: 1, schemaVersion: "1.0", releaseVersion: "1.0.0", payloads: [])
    }

    func loadPage(pageId: String) async throws -> PageEnvelope {
        try pageResult.get()
    }
}

@MainActor
struct PageStoreTests {
    private func makeEnvelope() throws -> PageEnvelope {
        let data = Data("""
        { "schemaVersion": "1.0", "version": "1.0.0", "pageId": "home_loans", "sections": [] }
        """.utf8)
        return try PayloadDecoder.decode(data)
    }

    @Test
    func loadSucceedsAndTransitionsToLoaded() async throws {
        let store = PageStore(pageId: "home_loans", source: StubPayloadSource(pageResult: .success(try makeEnvelope())))
        #expect(store.loadState == .loading)
        await store.load()
        #expect(store.loadState == .loaded)
        #expect(store.sections.isEmpty)
    }

    @Test
    func loadFailureTransitionsToFailed() async {
        let store = PageStore(pageId: "home_loans", source: StubPayloadSource(pageResult: .failure(StubError())))
        await store.load()
        #expect(store.loadState == .failed)
    }

    @Test
    func toggleFlipsMembership() throws {
        let store = PageStore(pageId: "home_loans", source: StubPayloadSource(pageResult: .success(try makeEnvelope())))
        #expect(!store.toggledIds.contains("car_1"))
        store.toggle("car_1")
        #expect(store.toggledIds.contains("car_1"))
        store.toggle("car_1")
        #expect(!store.toggledIds.contains("car_1"))
    }

    @Test
    func selectedChipIdFallsBackToDefaultWhenUnset() throws {
        let store = PageStore(pageId: "home_loans", source: StubPayloadSource(pageResult: .success(try makeEnvelope())))
        #expect(store.selectedChipId(forSection: "used_cars_rail", default: "wishlisted") == "wishlisted")
        store.selectChip("hot_deals", forSection: "used_cars_rail")
        #expect(store.selectedChipId(forSection: "used_cars_rail", default: "wishlisted") == "hot_deals")
    }
}
