//
//  RawItemEnvelopeTests.swift
//  SwiftUISDUITests
//
//  Executed tests for design_spec.md §3.3 step 1's raw wrapper: id/type
//  extraction, and one-level-only fallback exposure via superDecoder.
//

import Foundation
@testable import SwiftUISDUI
import Testing

private func decodeEnvelope(_ json: String) throws -> RawItemEnvelope {
    try JSONDecoder().decode(RawItemEnvelope.self, from: Data(json.utf8))
}

struct RawItemEnvelopeTests {

    @Test
    func decodesIdAndType() throws {
        let envelope = try decodeEnvelope("""
        { "id": "buy_car_rail__all_used_cars", "type": "tile", "title": "All used cars" }
        """)
        #expect(envelope.id == "buy_car_rail__all_used_cars")
        #expect(envelope.type == "tile")
    }

    @Test
    func absentFallbackYieldsNilDecoder() throws {
        let envelope = try decodeEnvelope("""
        { "id": "x", "type": "lottieTile", "src": "x.json" }
        """)
        #expect(envelope.fallbackDecoder == nil)
    }

    @Test
    func presentFallbackExposesItsOwnRawEnvelope() throws {
        let envelope = try decodeEnvelope("""
        {
          "id": "demo_unknown_with_fallback",
          "type": "videoTile",
          "videoUrl": "https://example.com/v.mp4",
          "fallback": {
            "id": "demo_unknown_with_fallback__fb",
            "type": "tile",
            "title": "Watch our story"
          }
        }
        """)
        let fallbackDecoder = try #require(envelope.fallbackDecoder)
        let fallbackEnvelope = try RawItemEnvelope(from: fallbackDecoder)
        #expect(fallbackEnvelope.id == "demo_unknown_with_fallback__fb")
        #expect(fallbackEnvelope.type == "tile")
        #expect(fallbackEnvelope.fallbackDecoder == nil)
    }

    @Test
    func nestedFallbackIsStillExposedOneLevel() throws {
        // The "no nested fallback" rule (COMPONENTS.md §10) is enforced by
        // the caller (decodeItem, commit 9), not by the wrapper itself —
        // the wrapper's job is only to expose what's there.
        let envelope = try decodeEnvelope("""
        {
          "id": "a", "type": "unknownA",
          "fallback": {
            "id": "b", "type": "unknownB",
            "fallback": { "id": "c", "type": "tile", "title": "t" }
          }
        }
        """)
        let fallbackDecoder = try #require(envelope.fallbackDecoder)
        let fallbackEnvelope = try RawItemEnvelope(from: fallbackDecoder)
        #expect(fallbackEnvelope.fallbackDecoder != nil)
    }
}
