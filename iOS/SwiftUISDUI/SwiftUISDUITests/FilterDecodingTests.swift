//
//  FilterDecodingTests.swift
//  SwiftUISDUITests
//
//  Executed tests for COMPONENTS.md §7 (Filter/Chip) and the §10
//  defaultChipId fallback rule. Shapes lifted from
//  sdui-config/payloads/home_all.json's used_cars_rail filter.
//

import Foundation
@testable import SwiftUISDUI
import Testing

private func decodeFilter(_ json: String) throws -> FilterNode {
    let decoder = JSONDecoder()
    decoder.userInfo[.componentRegistry] = ComponentRegistry.shared
    return try decoder.decode(FilterNode.self, from: Data(json.utf8))
}

struct FilterNodeDecodingTests {

    @Test
    func decodesChipsAndDefaultChipIdMatchingAChip() throws {
        let filter = try decodeFilter("""
        {
          "defaultChipId": "wishlisted",
          "chips": [
            { "id": "wishlisted", "label": "Wishlisted", "items": [
              { "id": "a", "type": "carCard", "image": { "url": "https://placehold.co/1x1" }, "title": "t", "price": "p", "action": { "type": "navigate", "target": "x" } }
            ] },
            { "id": "hot_deals", "label": "Hot deals", "items": [] }
          ]
        }
        """)
        #expect(filter.chips.count == 2)
        #expect(filter.defaultChip.id == "wishlisted")
        #expect(filter.chips[0].items.count == 1)
    }

    // COMPONENTS.md §10: defaultChipId matches no chip → index 0.
    @Test
    func defaultChipIdNotMatchingAnyChipFallsBackToIndexZero() throws {
        let filter = try decodeFilter("""
        {
          "defaultChipId": "nonexistent",
          "chips": [
            { "id": "wishlisted", "label": "Wishlisted", "items": [] },
            { "id": "hot_deals", "label": "Hot deals", "items": [] }
          ]
        }
        """)
        #expect(filter.defaultChip.id == "wishlisted")
    }

    @Test
    func fewerThanTwoChipsThrows() {
        #expect(throws: (any Error).self) {
            try decodeFilter("""
            { "defaultChipId": "only", "chips": [ { "id": "only", "label": "Only", "items": [] } ] }
            """)
        }
    }

    @Test
    func zeroChipsThrows() {
        #expect(throws: (any Error).self) {
            try decodeFilter("""
            { "defaultChipId": "x", "chips": [] }
            """)
        }
    }

    @Test
    func chipItemsDropUnknownTypesWithoutFallback() throws {
        let filter = try decodeFilter("""
        {
          "defaultChipId": "a",
          "chips": [
            { "id": "a", "label": "A", "items": [
              { "id": "x", "type": "tile", "title": "t", "action": { "type": "navigate", "target": "y" } },
              { "id": "y", "type": "lottieTile", "src": "x.json" }
            ] },
            { "id": "b", "label": "B", "items": [] }
          ]
        }
        """)
        #expect(filter.chips[0].items.count == 1)
        #expect(filter.chips[0].items.first?.id == "x")
    }
}
