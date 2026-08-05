//
//  ItemFallbackDecodingTests.swift
//  SwiftUISDUITests
//
//  Executed tests for design_spec.md §3.3 / COMPONENTS.md §10's full
//  item-level fallback table, via `decodeItem` and `ItemArray.decode`.
//  Scenarios mirror sdui-config/payloads/home_all_fallback_demo.json.
//

import Foundation
@testable import SwiftUISDUI
import Testing

private struct DecoderCapture: Decodable {
    let decoder: Decoder
    init(from decoder: Decoder) throws { self.decoder = decoder }
}

private func rawDecoder(_ json: String, registry: ComponentRegistry = .shared) throws -> Decoder {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.userInfo[.componentRegistry] = registry
    return try jsonDecoder.decode(DecoderCapture.self, from: Data(json.utf8)).decoder
}

struct DecodeItemTests {

    @Test
    func knownTypeNoFallbackNeededDecodesDirectly() throws {
        let decoder = try rawDecoder("""
        { "id": "x", "type": "tile", "title": "t", "action": { "type": "navigate", "target": "y" } }
        """)
        let node = decodeItem(from: decoder)
        #expect(node is TileNode)
        #expect(node?.id == "x")
    }

    // mirrors demo_unknown_no_fallback: unknown type, no fallback
    @Test
    func unknownTypeNoFallbackReturnsNil() throws {
        let decoder = try rawDecoder("""
        { "id": "demo_unknown_no_fallback", "type": "lottieTile", "src": "x.json" }
        """)
        #expect(decodeItem(from: decoder) == nil)
    }

    // mirrors demo_unknown_with_fallback: unknown type, known fallback
    @Test
    func unknownTypeWithKnownFallbackRendersTheFallback() throws {
        let decoder = try rawDecoder("""
        {
          "id": "demo_unknown_with_fallback", "type": "videoTile", "videoUrl": "https://example.com/v.mp4",
          "fallback": {
            "id": "demo_unknown_with_fallback__fb", "type": "tile", "title": "Watch our story",
            "action": { "type": "navigate", "target": "listing" }
          }
        }
        """)
        let node = decodeItem(from: decoder)
        let tile = try #require(node as? TileNode)
        #expect(tile.id == "demo_unknown_with_fallback__fb")
        #expect(tile.title == "Watch our story")
    }

    @Test
    func unknownTypeWithAlsoUnknownFallbackReturnsNil() throws {
        let decoder = try rawDecoder("""
        {
          "id": "a", "type": "unknownA",
          "fallback": { "id": "b", "type": "unknownB" }
        }
        """)
        #expect(decodeItem(from: decoder) == nil)
    }

    // COMPONENTS.md §10: "fallback itself unknown, or nested twice → Ignored. Item skipped."
    @Test
    func fallbackDeclaringItsOwnNestedFallbackIsIgnoredEntirely() throws {
        let decoder = try rawDecoder("""
        {
          "id": "a", "type": "unknownA",
          "fallback": {
            "id": "b", "type": "tile", "title": "should not render",
            "action": { "type": "navigate", "target": "x" },
            "fallback": { "id": "c", "type": "tile", "title": "also should not render" }
          }
        }
        """)
        #expect(decodeItem(from: decoder) == nil)
    }

    // mirrors demo_carcard_missing_price: known type, missing mandatory prop, no fallback
    @Test
    func knownTypeMissingMandatoryPropNoFallbackReturnsNil() throws {
        let decoder = try rawDecoder("""
        {
          "id": "demo_carcard_missing_price", "type": "carCard",
          "image": { "url": "https://placehold.co/1x1" }, "title": "t",
          "action": { "type": "navigate", "target": "y" }
        }
        """)
        #expect(decodeItem(from: decoder) == nil)
    }

    // COMPONENTS.md §10: "Known type, missing mandatory prop | Same as unknown
    // type: try fallback, else skip" — a case not present verbatim in the demo
    // payload but required by the table's literal wording.
    @Test
    func knownTypeMissingMandatoryPropWithFallbackRendersTheFallback() throws {
        let decoder = try rawDecoder("""
        {
          "id": "x", "type": "carCard",
          "image": { "url": "https://placehold.co/1x1" }, "title": "t",
          "action": { "type": "navigate", "target": "y" },
          "fallback": {
            "id": "x__fb", "type": "tile", "title": "fallback tile",
            "action": { "type": "navigate", "target": "y" }
          }
        }
        """)
        let node = decodeItem(from: decoder)
        let tile = try #require(node as? TileNode)
        #expect(tile.id == "x__fb")
    }

    // mirrors demo_select_action: an unrecognized action.type still decodes.
    @Test
    func unrecognizedActionTypeDoesNotPreventDecoding() throws {
        let decoder = try rawDecoder("""
        {
          "id": "demo_select_action", "type": "tile", "title": "Select action (no-op)",
          "action": { "type": "select", "target": "used_cars_rail", "params": { "datasetId": "hot_deals" } }
        }
        """)
        let tile = try #require(decodeItem(from: decoder) as? TileNode)
        #expect(tile.action.type == "select")
    }

    @Test
    func missingRegistryInUserInfoReturnsNilInsteadOfCrashing() throws {
        let jsonDecoder = JSONDecoder()
        let decoder = try jsonDecoder.decode(DecoderCapture.self, from: Data("""
        { "id": "x", "type": "tile", "title": "t", "action": { "type": "navigate", "target": "y" } }
        """.utf8)).decoder
        #expect(decodeItem(from: decoder) == nil)
    }
}

struct ItemArrayDecodingTests {

    private func rawArrayDecoder(_ json: String) throws -> Decoder {
        try rawDecoder(json)
    }

    // mirrors sdui-config/payloads/home_all_fallback_demo.json's buy_car_rail
    @Test
    func dropsUnknownItemsAndKeepsSiblingsInOrder() throws {
        let decoder = try rawArrayDecoder("""
        [
          { "id": "a", "type": "tile", "title": "All used cars", "action": { "type": "navigate", "target": "x" } },
          {
            "id": "demo_unknown_with_fallback", "type": "videoTile",
            "fallback": {
              "id": "demo_unknown_with_fallback__fb", "type": "tile", "title": "Watch our story",
              "action": { "type": "navigate", "target": "listing" }
            }
          },
          { "id": "b", "type": "tile", "title": "Budget used cars", "action": { "type": "navigate", "target": "x" } },
          { "id": "demo_unknown_no_fallback", "type": "lottieTile", "src": "x.json" },
          { "id": "c", "type": "tile", "title": "Premium used cars", "action": { "type": "navigate", "target": "x" } }
        ]
        """)
        var container = try decoder.unkeyedContainer()
        let items = try ItemArray.decode(from: &container)
        #expect(items.map(\.id) == ["a", "demo_unknown_with_fallback__fb", "b", "c"])
    }

    @Test
    func emptyArrayDecodesToEmpty() throws {
        let decoder = try rawArrayDecoder("[]")
        var container = try decoder.unkeyedContainer()
        let items = try ItemArray.decode(from: &container)
        #expect(items.isEmpty)
    }
}
