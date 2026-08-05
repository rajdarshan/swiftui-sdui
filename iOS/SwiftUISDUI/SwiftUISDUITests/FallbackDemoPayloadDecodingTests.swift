//
//  FallbackDemoPayloadDecodingTests.swift
//  SwiftUISDUITests
//
//  Executed, end-to-end coverage of every COMPONENTS.md §10 fallback
//  scenario decoding simultaneously from one payload — trimmed from
//  sdui-config/payloads/home_all_fallback_demo.json (id/type/title values
//  preserved verbatim; unrelated fields and sections cut for brevity, cited
//  per section below). Also the "old-client" regression test
//  (ADDING_A_COMPONENT.md §5: "the one people skip") — a registry missing a
//  type entirely must still decode the rest of the page without crashing.
//

import Foundation
@testable import SwiftUISDUI
import Testing

// Trimmed from sdui-config/payloads/home_all_fallback_demo.json:
// - buy_car_rail: all 4 of its demonstrative items (unknown+fallback,
//   plain tile, unknown+no-fallback), matching the real payload verbatim.
// - demo_unknown_section: unknown section type, verbatim.
// - used_cars_rail: filter with the wishlisted chip's missing-price item,
//   trimmed to 2 valid cars instead of 3 (content-equivalent, fewer lines),
//   plus a minimal hot_deals chip to satisfy the 2-chip minimum.
private let fallbackDemoPayload = Data("""
{
  "schemaVersion": "1.0", "version": "1.0.0", "pageId": "home_all_fallback_demo",
  "sections": [
    {
      "id": "buy_car_rail", "type": "rail", "itemWidth": "sm",
      "items": [
        {
          "id": "buy_car_rail__all_used_cars", "type": "tile", "title": "All used cars",
          "action": { "type": "navigate", "target": "listing", "params": { "filter": "all" } }
        },
        {
          "id": "demo_unknown_with_fallback", "type": "videoTile",
          "videoUrl": "https://example.com/v.mp4", "title": "Video tile",
          "fallback": {
            "id": "demo_unknown_with_fallback__fb", "type": "tile", "title": "Watch our story",
            "action": { "type": "navigate", "target": "listing" }
          }
        },
        {
          "id": "buy_car_rail__budget_used_cars", "type": "tile", "title": "Budget used cars",
          "action": { "type": "navigate", "target": "listing", "params": { "filter": "budget" } }
        },
        { "id": "demo_unknown_no_fallback", "type": "lottieTile", "src": "x.json" }
      ]
    },
    {
      "id": "demo_unknown_section", "type": "storyReel",
      "header": { "title": "Stories (unknown section)" },
      "items": []
    },
    {
      "id": "used_cars_rail", "type": "rail", "itemWidth": "lg",
      "filter": {
        "defaultChipId": "wishlisted",
        "chips": [
          {
            "id": "wishlisted", "label": "Wishlisted",
            "items": [
              {
                "id": "used_cars_rail_wishlisted__2023_mahindra_xuv300", "type": "carCard",
                "image": { "url": "https://placehold.co/600x400" },
                "title": "2023 Mahindra XUV300", "price": "\\u20b96.60 lakh",
                "action": { "type": "navigate", "target": "car_detail", "params": { "carId": "car_10021" } }
              },
              {
                "id": "demo_carcard_missing_price", "type": "carCard",
                "image": { "url": "https://placehold.co/600x400" },
                "title": "2023 Mahindra XUV300",
                "action": { "type": "navigate", "target": "car_detail", "params": { "carId": "car_10021" } }
              }
            ]
          },
          {
            "id": "hot_deals", "label": "Hot deals",
            "items": [
              {
                "id": "used_cars_rail_hot_deals__2019_maruti_swift", "type": "carCard",
                "image": { "url": "https://placehold.co/600x400" },
                "title": "2019 Maruti Swift", "price": "\\u20b94.95 lakh",
                "action": { "type": "navigate", "target": "car_detail", "params": { "carId": "car_10031" } }
              }
            ]
          }
        ]
      }
    }
  ]
}
""".utf8)

struct FallbackDemoPayloadDecodingTests {

    @Test
    func unknownSectionIsAbsentSiblingsSurvive() throws {
        let envelope = try PayloadDecoder.decode(fallbackDemoPayload)
        #expect(envelope.sections.map(\.id) == ["buy_car_rail", "used_cars_rail"])
    }

    @Test
    func buyCarRailRendersTheFallbackTileButDropsTheUnfallenBackItem() throws {
        let envelope = try PayloadDecoder.decode(fallbackDemoPayload)
        guard case .rail(let rail) = envelope.sections[0] else {
            Issue.record("expected buy_car_rail to decode as .rail")
            return
        }
        // 3 rendered: all_used_cars, the videoTile's fallback tile, budget_used_cars.
        // demo_unknown_no_fallback (lottieTile) is dropped entirely.
        #expect(rail.items?.map(\.id) == [
            "buy_car_rail__all_used_cars",
            "demo_unknown_with_fallback__fb",
            "buy_car_rail__budget_used_cars"
        ])
        let fallbackTile = try #require(rail.items?[1] as? TileNode)
        #expect(fallbackTile.title == "Watch our story")
    }

    @Test
    func usedCarsRailWishlistedChipDropsTheMissingPriceCarCard() throws {
        let envelope = try PayloadDecoder.decode(fallbackDemoPayload)
        guard case .rail(let rail) = envelope.sections[1] else {
            Issue.record("expected used_cars_rail to decode as .rail")
            return
        }
        let wishlisted = try #require(rail.filter?.chips.first { $0.id == "wishlisted" })
        #expect(wishlisted.items.map(\.id) == ["used_cars_rail_wishlisted__2023_mahindra_xuv300"])
    }

    // ADDING_A_COMPONENT.md §5: "Old-client behaviour... the one people skip and
    // the one the assignment explicitly asks you to demonstrate."
    @Test
    @MainActor
    func oldClientRegistryMissingCarCardStillDecodesTheRestOfThePageWithoutCrashing() throws {
        var decoders = ComponentRegistry.shared.itemDecoders
        decoders.removeValue(forKey: "carCard")
        let oldClientRegistry = ComponentRegistry(itemDecoders: decoders, itemViews: [:])

        let envelope = try PayloadDecoder.decode(fallbackDemoPayload, registry: oldClientRegistry)

        // Sections still present, buy_car_rail unaffected (no carCard there).
        #expect(envelope.sections.map(\.id) == ["buy_car_rail", "used_cars_rail"])
        guard case .rail(let buyCarRail) = envelope.sections[0] else {
            Issue.record("expected buy_car_rail to decode as .rail")
            return
        }
        #expect(buyCarRail.items?.count == 3)

        // used_cars_rail's chips render with zero carCard items — no fallback
        // was declared for them, so both drop, but the page doesn't crash
        // and every other node still renders.
        guard case .rail(let usedCarsRail) = envelope.sections[1] else {
            Issue.record("expected used_cars_rail to decode as .rail")
            return
        }
        let allChipItems = usedCarsRail.filter?.chips.flatMap(\.items) ?? []
        #expect(allChipItems.isEmpty)
    }
}
