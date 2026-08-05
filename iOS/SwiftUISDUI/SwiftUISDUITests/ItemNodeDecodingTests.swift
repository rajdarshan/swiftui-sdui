//
//  ItemNodeDecodingTests.swift
//  SwiftUISDUITests
//
//  Executed tests: one happy-path decode per item type against JSON lifted
//  from sdui-config/payloads/home_all.json, plus a check that a missing
//  mandatory field throws (the node's half of design_spec.md §3.3's
//  "one code path covers unknown type and known-type-missing-prop" —
//  decodeItem's fallback wrapping is covered separately, commit 9).
//

import Foundation
@testable import SwiftUISDUI
import Testing

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try JSONDecoder().decode(type, from: Data(json.utf8))
}

struct TileNodeDecodingTests {

    // sdui-config/payloads/home_all.json: buy_car_rail__all_used_cars
    @Test
    func decodesHappyPath() throws {
        let node = try decode(TileNode.self, """
        {
          "id": "buy_car_rail__all_used_cars",
          "type": "tile",
          "title": "All used cars",
          "image": { "url": "https://placehold.co/240x160", "aspect": 1.5 },
          "style": { "background": "tile.blue", "foreground": "text.onDark", "cornerRadius": "lg" },
          "action": { "type": "navigate", "target": "listing", "params": { "filter": "all" } }
        }
        """)
        #expect(node.id == "buy_car_rail__all_used_cars")
        #expect(node.type == "tile")
        #expect(node.title == "All used cars")
        #expect(node.image?.aspect == 1.5)
        #expect(node.style?.background == Palette.tileBlue)
        #expect(node.action.target == "listing")
    }

    @Test
    func absentImageAndStyleAreNil() throws {
        let node = try decode(TileNode.self, """
        { "id": "x", "type": "tile", "title": "t", "action": { "type": "navigate", "target": "y" } }
        """)
        #expect(node.image == nil)
        #expect(node.style == nil)
    }

    @Test
    func missingMandatoryTitleThrows() {
        #expect(throws: (any Error).self) {
            try decode(TileNode.self, """
            { "id": "x", "type": "tile", "action": { "type": "navigate", "target": "y" } }
            """)
        }
    }
}

struct ModelCardNodeDecodingTests {

    // sdui-config/payloads/home_all.json: trending_new_cars_rail__seltos
    @Test
    func decodesHappyPath() throws {
        let node = try decode(ModelCardNode.self, """
        {
          "id": "trending_new_cars_rail__seltos",
          "type": "modelCard",
          "title": "Seltos",
          "subtitle": "Kia",
          "image": { "url": "https://placehold.co/600x400", "aspect": 1.5 },
          "watermark": "1",
          "style": { "background": "surface.muted", "cornerRadius": "lg" },
          "action": { "type": "navigate", "target": "new_car_detail", "params": { "modelId": "kia_seltos" } }
        }
        """)
        #expect(node.title == "Seltos")
        #expect(node.subtitle == "Kia")
        #expect(node.watermark == "1")
        #expect(node.image.aspect == 1.5)
    }

    @Test
    func missingMandatoryImageThrows() {
        #expect(throws: (any Error).self) {
            try decode(ModelCardNode.self, """
            { "id": "x", "type": "modelCard", "title": "t", "action": { "type": "navigate", "target": "y" } }
            """)
        }
    }
}

struct IconTileNodeDecodingTests {

    // sdui-config/payloads/home_all.json: loans_rail__used_car_loan
    @Test
    func decodesHappyPath() throws {
        let node = try decode(IconTileNode.self, """
        {
          "id": "loans_rail__used_car_loan",
          "type": "iconTile",
          "label": "Used car loan",
          "image": { "url": "https://placehold.co/280x280", "aspect": 1.0 },
          "imageShape": "arch",
          "action": { "type": "navigate", "target": "loan", "params": { "product": "used_car" } }
        }
        """)
        #expect(node.label == "Used car loan")
        #expect(node.imageShape == .arch)
    }

    @Test
    func absentImageShapeDefaultsToSquare() throws {
        let node = try decode(IconTileNode.self, """
        {
          "id": "x", "type": "iconTile", "label": "l",
          "image": { "url": "https://placehold.co/1x1" },
          "action": { "type": "navigate", "target": "y" }
        }
        """)
        #expect(node.imageShape == .square)
    }

    @Test
    func unknownImageShapeDefaultsToSquare() throws {
        let node = try decode(IconTileNode.self, """
        {
          "id": "x", "type": "iconTile", "label": "l",
          "image": { "url": "https://placehold.co/1x1" },
          "imageShape": "hexagon",
          "action": { "type": "navigate", "target": "y" }
        }
        """)
        #expect(node.imageShape == .square)
    }

    @Test
    func missingMandatoryImageThrows() {
        #expect(throws: (any Error).self) {
            try decode(IconTileNode.self, """
            { "id": "x", "type": "iconTile", "label": "l", "action": { "type": "navigate", "target": "y" } }
            """)
        }
    }
}
