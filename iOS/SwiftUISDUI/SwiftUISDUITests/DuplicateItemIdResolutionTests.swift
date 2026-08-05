//
//  DuplicateItemIdResolutionTests.swift
//  SwiftUISDUITests
//
//  Executed tests for COMPONENTS.md §10: "Duplicate item id within a page |
//  Decoder logs; last occurrence wins." Exercised through
//  `PayloadDecoder.decode` end to end, since that's the only public entry
//  point that wires dedup in.
//

import Foundation
@testable import SwiftUISDUI
import Testing

struct DuplicateItemIdResolutionTests {

    @Test
    func laterOccurrenceAcrossTwoSectionsWinsOverEarlier() throws {
        let data = Data("""
        {
          "schemaVersion": "1.0", "version": "1.0.0", "pageId": "x",
          "sections": [
            {
              "id": "rail_a", "type": "rail", "itemWidth": "sm",
              "items": [
                { "id": "dup", "type": "tile", "title": "first (earlier)", "action": { "type": "navigate", "target": "x" } }
              ]
            },
            {
              "id": "rail_b", "type": "rail", "itemWidth": "sm",
              "items": [
                { "id": "dup", "type": "tile", "title": "second (later, wins)", "action": { "type": "navigate", "target": "x" } }
              ]
            }
          ]
        }
        """.utf8)
        let envelope = try PayloadDecoder.decode(data)

        guard case .rail(let firstRail) = envelope.sections[0], case .rail(let secondRail) = envelope.sections[1] else {
            Issue.record("expected two rail sections")
            return
        }
        #expect(firstRail.items?.isEmpty == true)
        #expect(secondRail.items?.count == 1)
        let winner = try #require(secondRail.items?.first as? TileNode)
        #expect(winner.title == "second (later, wins)")
    }

    @Test
    func orderOfNonDuplicatedItemsIsUnaffected() throws {
        let data = Data("""
        {
          "schemaVersion": "1.0", "version": "1.0.0", "pageId": "x",
          "sections": [
            {
              "id": "rail_a", "type": "rail", "itemWidth": "sm",
              "items": [
                { "id": "a", "type": "tile", "title": "a", "action": { "type": "navigate", "target": "x" } },
                { "id": "b", "type": "tile", "title": "b", "action": { "type": "navigate", "target": "x" } }
              ]
            }
          ]
        }
        """.utf8)
        let envelope = try PayloadDecoder.decode(data)
        guard case .rail(let rail) = envelope.sections[0] else {
            Issue.record("expected a rail section")
            return
        }
        #expect(rail.items?.map(\.id) == ["a", "b"])
    }

    @Test
    func duplicateAcrossAFilterChipAndAPlainRailIsResolved() throws {
        let data = Data("""
        {
          "schemaVersion": "1.0", "version": "1.0.0", "pageId": "x",
          "sections": [
            {
              "id": "rail_a", "type": "rail", "itemWidth": "sm",
              "items": [
                { "id": "dup", "type": "tile", "title": "earlier", "action": { "type": "navigate", "target": "x" } }
              ]
            },
            {
              "id": "rail_filtered", "type": "rail", "itemWidth": "lg",
              "filter": {
                "defaultChipId": "a",
                "chips": [
                  { "id": "a", "label": "A", "items": [
                    { "id": "dup", "type": "tile", "title": "later (wins)", "action": { "type": "navigate", "target": "x" } }
                  ] },
                  { "id": "b", "label": "B", "items": [] }
                ]
              }
            }
          ]
        }
        """.utf8)
        let envelope = try PayloadDecoder.decode(data)
        guard case .rail(let plainRail) = envelope.sections[0], case .rail(let filteredRail) = envelope.sections[1] else {
            Issue.record("expected two rail sections")
            return
        }
        #expect(plainRail.items?.isEmpty == true)
        #expect(filteredRail.filter?.chips.first?.items.count == 1)
    }

    @Test
    func noDuplicatesLeavesTheTreeUnchanged() throws {
        let data = Data("""
        {
          "schemaVersion": "1.0", "version": "1.0.0", "pageId": "x",
          "sections": [
            {
              "id": "single_a", "type": "single",
              "item": { "id": "unique", "type": "textBlock", "title": "t" }
            }
          ]
        }
        """.utf8)
        let envelope = try PayloadDecoder.decode(data)
        guard case .single(let node) = envelope.sections[0] else {
            Issue.record("expected a single section")
            return
        }
        #expect(node.item.id == "unique")
    }
}
