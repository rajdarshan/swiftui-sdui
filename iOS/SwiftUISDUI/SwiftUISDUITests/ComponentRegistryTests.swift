//
//  ComponentRegistryTests.swift
//  SwiftUISDUITests
//
//  Executed tests for the registry's decode-closure table
//  (design_spec.md §3.2 rule 3) — the seam decodeItem (commit 9) dispatches
//  through. `DecoderCapture` mirrors what RawItemEnvelope-driven dispatch
//  does: obtain one `Decoder` from JSONDecoder, then hand that same
//  `Decoder` to an arbitrary decode closure.
//

import Foundation
@testable import SwiftUISDUI
import Testing

private struct DecoderCapture: Decodable {
    let decoder: Decoder
    init(from decoder: Decoder) throws { self.decoder = decoder }
}

private func rawDecoder(_ json: String) throws -> Decoder {
    try JSONDecoder().decode(DecoderCapture.self, from: Data(json.utf8)).decoder
}

struct ComponentRegistryTests {

    @Test
    func containsAllEightItemTypesFromComponentsMd8() {
        let expected: Set<String> = [
            "tile", "modelCard", "iconTile", "carCard",
            "placeCard", "promoCard", "featureCard", "textBlock"
        ]
        #expect(Set(ComponentRegistry.shared.itemDecoders.keys) == expected)
    }

    @Test
    func unknownTypeHasNoDecoder() {
        #expect(ComponentRegistry.shared.itemDecoders["videoTile"] == nil)
    }

    @Test
    func tileDecoderProducesATileNode() throws {
        let decoder = try rawDecoder("""
        {
          "id": "x", "type": "tile", "title": "t",
          "action": { "type": "navigate", "target": "y" }
        }
        """)
        let decode = try #require(ComponentRegistry.shared.itemDecoders["tile"])
        let node = try decode(decoder) as? TileNode
        #expect(node?.title == "t")
    }

    @Test
    func carCardDecoderThrowsOnMissingMandatoryPrice() throws {
        let decoder = try rawDecoder("""
        {
          "id": "x", "type": "carCard",
          "image": { "url": "https://placehold.co/1x1" },
          "title": "t",
          "action": { "type": "navigate", "target": "y" }
        }
        """)
        let decode = try #require(ComponentRegistry.shared.itemDecoders["carCard"])
        #expect(throws: (any Error).self) {
            try decode(decoder)
        }
    }
}
