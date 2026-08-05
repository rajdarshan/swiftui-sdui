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

    // Regression: effectiveCarCardFavorite must key off favorite.action.target
    // (COMPONENTS.md §4.1's toggle "Entity id"), not the item's own page-scoped
    // id (COMPONENTS.md §8) — a prior bug checked the wrong one, so the
    // wishlist heart never visually toggled. This is the exact mismatch
    // confirmed in sdui-config/payloads/home_all.json: item id
    // "used_cars_rail_wishlisted__2023_mahindra_xuv300" vs. its favorite's
    // action.target "car_10021".
    @MainActor
    @Test
    func effectiveFavoriteTogglesOnTheActionTargetNotTheItemId() throws {
        let decoder = try rawDecoder("""
        {
          "id": "used_cars_rail_wishlisted__2023_mahindra_xuv300", "type": "carCard",
          "image": { "url": "https://placehold.co/1x1" }, "title": "t", "price": "p",
          "action": { "type": "navigate", "target": "car_detail" },
          "favorite": { "selected": false, "action": { "type": "toggle", "target": "car_10021" } }
        }
        """)
        let decode = try #require(ComponentRegistry.shared.itemDecoders["carCard"])
        let card = try #require(try decode(decoder) as? CarCardNode)

        let untouched = effectiveCarCardFavorite(for: card, context: ItemRenderContext())
        #expect(untouched?.selected == false)

        let toggledByItemId = effectiveCarCardFavorite(
            for: card,
            context: ItemRenderContext(toggledIds: [card.id])
        )
        #expect(toggledByItemId?.selected == false, "the item's own id must not flip the heart")

        let toggledByActionTarget = effectiveCarCardFavorite(
            for: card,
            context: ItemRenderContext(toggledIds: ["car_10021"])
        )
        #expect(toggledByActionTarget?.selected == true)
    }
}
