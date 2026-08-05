//
//  SectionDecodingTests.swift
//  SwiftUISDUITests
//
//  Executed tests for COMPONENTS.md §6 (section containers) and §10's
//  section-level fallback rule via `decodeSection`. Header section is
//  covered separately once HeaderSectionNode exists (a later commit).
//

import Foundation
@testable import SwiftUISDUI
import Testing

private struct DecoderCapture: Decodable {
    let decoder: Decoder
    init(from decoder: Decoder) throws { self.decoder = decoder }
}

private func rawDecoder(_ json: String) throws -> Decoder {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.userInfo[.componentRegistry] = ComponentRegistry.shared
    return try jsonDecoder.decode(DecoderCapture.self, from: Data(json.utf8)).decoder
}

struct DecodeSectionTests {

    // mirrors sdui-config/payloads/home_all_fallback_demo.json: demo_unknown_section
    @Test
    func unknownSectionTypeReturnsNil() throws {
        let decoder = try rawDecoder("""
        { "id": "demo_unknown_section", "type": "storyReel", "items": [] }
        """)
        #expect(decodeSection(from: decoder) == nil)
    }

    @Test
    func railWithItemsDecodes() throws {
        let decoder = try rawDecoder("""
        {
          "id": "buy_car_rail", "type": "rail", "itemWidth": "sm",
          "header": { "title": "Buy car" },
          "items": [
            { "id": "a", "type": "tile", "title": "t", "action": { "type": "navigate", "target": "x" } }
          ]
        }
        """)
        guard case .rail(let node) = decodeSection(from: decoder) else {
            Issue.record("expected .rail")
            return
        }
        #expect(node.items?.count == 1)
        #expect(node.itemWidth == .sm)
        #expect(node.header?.title == "Buy car")
    }

    @Test
    func railWithFilterHasNilItemsAndPopulatedFilter() throws {
        let decoder = try rawDecoder("""
        {
          "id": "used_cars_rail", "type": "rail", "itemWidth": "lg",
          "filter": {
            "defaultChipId": "wishlisted",
            "chips": [
              { "id": "wishlisted", "label": "Wishlisted", "items": [] },
              { "id": "hot_deals", "label": "Hot deals", "items": [] }
            ]
          }
        }
        """)
        guard case .rail(let node) = decodeSection(from: decoder) else {
            Issue.record("expected .rail")
            return
        }
        #expect(node.items == nil)
        #expect(node.filter?.chips.count == 2)
    }

    @Test
    func railWithNeitherItemsNorFilterReturnsNil() throws {
        let decoder = try rawDecoder("""
        { "id": "x", "type": "rail" }
        """)
        #expect(decodeSection(from: decoder) == nil)
    }

    @Test
    func gridWithValidColumnsDecodes() throws {
        let decoder = try rawDecoder("""
        {
          "id": "car_check_grid", "type": "grid", "columns": 3,
          "items": [
            { "id": "a", "type": "tile", "title": "t", "action": { "type": "navigate", "target": "x" } }
          ]
        }
        """)
        guard case .grid(let node) = decodeSection(from: decoder) else {
            Issue.record("expected .grid")
            return
        }
        #expect(node.columns == 3)
    }

    // resolved ambiguity: out-of-range columns treated as malformed → section dropped.
    @Test
    func gridWithOutOfRangeColumnsReturnsNil() throws {
        let decoder = try rawDecoder("""
        { "id": "x", "type": "grid", "columns": 6, "items": [] }
        """)
        #expect(decodeSection(from: decoder) == nil)
    }

    @Test
    func carouselDecodesWithStatedValuesAndDefaults() throws {
        let decoder = try rawDecoder("""
        {
          "id": "value_prop_carousel", "type": "carousel", "loop": true, "peek": true, "autoScrollMs": 4000,
          "items": [
            { "id": "a", "type": "promoCard", "title": "t" }
          ]
        }
        """)
        guard case .carousel(let node) = decodeSection(from: decoder) else {
            Issue.record("expected .carousel")
            return
        }
        #expect(node.loop == true)
        #expect(node.peek == true)
        #expect(node.autoScrollMs == 4000)
    }

    @Test
    func carouselAbsentLoopAndPeekDefaultToFalse() throws {
        let decoder = try rawDecoder("""
        { "id": "x", "type": "carousel", "items": [] }
        """)
        guard case .carousel(let node) = decodeSection(from: decoder) else {
            Issue.record("expected .carousel")
            return
        }
        #expect(node.loop == false)
        #expect(node.peek == false)
        #expect(node.autoScrollMs == nil)
    }

    @Test
    func singleDecodesItsOneItem() throws {
        let decoder = try rawDecoder("""
        {
          "id": "find_match_card", "type": "single",
          "item": { "id": "find_match_card__x", "type": "featureCard", "title": "Let us find your match" }
        }
        """)
        guard case .single(let node) = decodeSection(from: decoder) else {
            Issue.record("expected .single")
            return
        }
        #expect(node.item.id == "find_match_card__x")
    }

    @Test
    func singleWithMissingItemReturnsNil() throws {
        let decoder = try rawDecoder("""
        { "id": "x", "type": "single" }
        """)
        #expect(decodeSection(from: decoder) == nil)
    }
}
