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

struct CarCardNodeDecodingTests {

    // sdui-config/payloads/home_all.json: used_cars_rail_wishlisted__2023_mahindra_xuv300
    @Test
    func decodesHappyPath() throws {
        let node = try decode(CarCardNode.self, """
        {
          "id": "used_cars_rail_wishlisted__2023_mahindra_xuv300",
          "type": "carCard",
          "image": { "url": "https://placehold.co/600x400", "aspect": 1.5 },
          "overlayBadge": { "text": "Owned stock", "variant": "accent" },
          "favorite": { "selected": true, "action": { "type": "toggle", "target": "car_10021" } },
          "title": "2023 Mahindra XUV300",
          "subtitle": "W6 1.2 PETROL",
          "specs": ["25,335 km", "Petrol", "Manual", "MH28"],
          "price": "\\u20b96.60 lakh",
          "priceSuffix": "EMI \\u20b911,651/m*",
          "priceNote": { "text": "+other charges", "action": { "type": "openSheet", "target": "price_breakup" } },
          "trustBadges": [{ "text": "Zero Worry Max", "icon": "shield", "variant": "accent" }],
          "action": { "type": "navigate", "target": "car_detail", "params": { "carId": "car_10021" } }
        }
        """)
        #expect(node.title == "2023 Mahindra XUV300")
        #expect(node.specs == ["25,335 km", "Petrol", "Manual", "MH28"])
        #expect(node.favorite?.selected == true)
        #expect(node.trustBadges.count == 1)
    }

    @Test
    func absentSpecsAndTrustBadgesDefaultToEmpty() throws {
        let node = try decode(CarCardNode.self, """
        {
          "id": "x", "type": "carCard",
          "image": { "url": "https://placehold.co/1x1" },
          "title": "t", "price": "p",
          "action": { "type": "navigate", "target": "y" }
        }
        """)
        #expect(node.specs.isEmpty)
        #expect(node.trustBadges.isEmpty)
    }

    // mirrors sdui-config/payloads/home_all_fallback_demo.json: demo_carcard_missing_price
    @Test
    func missingMandatoryPriceThrows() {
        #expect(throws: (any Error).self) {
            try decode(CarCardNode.self, """
            {
              "id": "demo_carcard_missing_price", "type": "carCard",
              "image": { "url": "https://placehold.co/1x1" },
              "title": "t",
              "action": { "type": "navigate", "target": "y" }
            }
            """)
        }
    }
}

struct PlaceCardNodeDecodingTests {

    // sdui-config/payloads/home_all.json: showrooms_rail__right_parking_mlcp
    @Test
    func decodesHappyPathWithMultipleImagesAndTwoButtons() throws {
        let node = try decode(PlaceCardNode.self, """
        {
          "id": "showrooms_rail__right_parking_mlcp",
          "type": "placeCard",
          "images": [
            { "url": "https://placehold.co/900x600a" },
            { "url": "https://placehold.co/900x600b" }
          ],
          "overlayBadge": { "text": "90+ cars" },
          "title": "Right Parking MLCP",
          "subtitle": "Gandhi Nagar, Bengaluru",
          "linkRow": {
            "text": "2.7 km from MG Road | Get directions",
            "trailingIcon": "directions",
            "action": { "type": "openMaps", "target": "showroom_101" }
          },
          "status": { "text": "Open", "detail": "Closes at 08:00 PM", "variant": "success" },
          "buttons": [
            { "text": "Call us now", "variant": "outline", "leadingIcon": "phone", "action": { "type": "call", "target": "x" } },
            { "text": "View showroom", "action": { "type": "navigate", "target": "showroom_detail" } }
          ]
        }
        """)
        #expect(node.images.count == 2)
        #expect(node.buttons.count == 2)
        #expect(node.linkRow?.trailingIcon == IconToken.directions)
        #expect(node.status?.variant == .success)
    }

    @Test
    func singleImageDecodesFine() throws {
        let node = try decode(PlaceCardNode.self, """
        { "id": "x", "type": "placeCard", "images": [{ "url": "https://placehold.co/1x1" }], "title": "t" }
        """)
        #expect(node.images.count == 1)
        #expect(node.buttons.isEmpty)
    }

    @Test
    func emptyImagesArrayThrows() {
        // COMPONENTS.md §8: images min 1 — resolved as malformed, not just "absent."
        #expect(throws: (any Error).self) {
            try decode(PlaceCardNode.self, """
            { "id": "x", "type": "placeCard", "images": [], "title": "t" }
            """)
        }
    }

    @Test
    func moreThanTwoButtonsThrows() {
        #expect(throws: (any Error).self) {
            try decode(PlaceCardNode.self, """
            {
              "id": "x", "type": "placeCard",
              "images": [{ "url": "https://placehold.co/1x1" }],
              "title": "t",
              "buttons": [
                { "text": "a", "action": { "type": "navigate", "target": "x" } },
                { "text": "b", "action": { "type": "navigate", "target": "x" } },
                { "text": "c", "action": { "type": "navigate", "target": "x" } }
              ]
            }
            """)
        }
    }
}

struct PromoCardNodeDecodingTests {

    // sdui-config/payloads/home_all.json: orbit_promo__add_your_car_to_orbit
    @Test
    func decodesHappyPath() throws {
        let node = try decode(PromoCardNode.self, """
        {
          "id": "orbit_promo__add_your_car_to_orbit",
          "type": "promoCard",
          "title": "Add your car to Orbit",
          "subtitle": "Enjoy 3 months of music streaming free",
          "image": { "url": "https://placehold.co/720x400", "aspect": 1.8 },
          "logos": [{ "url": "https://placehold.co/160x40a" }, { "url": "https://placehold.co/160x40b" }],
          "button": { "text": "Add car now", "action": { "type": "openSheet", "target": "add_vehicle" } },
          "style": { "background": "tile.dark", "foreground": "text.onDark", "cornerRadius": "lg" }
        }
        """)
        #expect(node.title == "Add your car to Orbit")
        #expect(node.logos.count == 2)
        #expect(node.button?.text == "Add car now")
        #expect(node.style?.background == Palette.tileDark)
    }

    @Test
    func absentLogosDefaultsToEmptyAndOnlyTitleIsMandatory() throws {
        let node = try decode(PromoCardNode.self, """
        { "id": "x", "type": "promoCard", "title": "t" }
        """)
        #expect(node.logos.isEmpty)
        #expect(node.image == nil)
        #expect(node.button == nil)
    }
}

struct FeatureCardNodeDecodingTests {

    // sdui-config/payloads/home_all.json: find_match_card__let_us_find_your_match
    @Test
    func decodesHappyPathWithBodyKeyMappedToBodyText() throws {
        let node = try decode(FeatureCardNode.self, """
        {
          "id": "find_match_card__let_us_find_your_match",
          "type": "featureCard",
          "badge": { "text": "Recommended", "variant": "accent" },
          "title": "Let us find your match",
          "body": "Answer a few simple questions and get your perfect car match in 60 seconds.",
          "image": { "url": "https://placehold.co/400x600", "aspect": 0.67 },
          "imagePosition": "leading",
          "footer": {
            "text": "Find my perfect match",
            "trailingIcon": "arrowRightCircle",
            "action": { "type": "navigate", "target": "match_quiz" }
          }
        }
        """)
        #expect(node.title == "Let us find your match")
        #expect(node.bodyText == "Answer a few simple questions and get your perfect car match in 60 seconds.")
        #expect(node.imagePosition == .leading)
        #expect(node.footer?.trailingIcon == IconToken.arrowRightCircle)
        #expect(node.badge?.variant == .accent)
    }

    @Test
    func absentImagePositionDefaultsToLeading() throws {
        let node = try decode(FeatureCardNode.self, """
        { "id": "x", "type": "featureCard", "title": "t" }
        """)
        #expect(node.imagePosition == .leading)
        #expect(node.bodyText == nil)
        #expect(node.footer == nil)
    }

    @Test
    func unknownImagePositionDefaultsToLeading() throws {
        let node = try decode(FeatureCardNode.self, """
        { "id": "x", "type": "featureCard", "title": "t", "imagePosition": "diagonal" }
        """)
        #expect(node.imagePosition == .leading)
    }

    @Test
    func missingMandatoryTitleThrows() {
        #expect(throws: (any Error).self) {
            try decode(FeatureCardNode.self, "{ \"id\": \"x\", \"type\": \"featureCard\" }")
        }
    }
}

struct TextBlockNodeDecodingTests {

    // sdui-config/payloads/home_all.json: brand_footer__better_drives_better_lives
    @Test
    func decodesHappyPath() throws {
        let node = try decode(TextBlockNode.self, """
        {
          "id": "brand_footer__better_drives_better_lives",
          "type": "textBlock",
          "title": "better drives, better lives",
          "subtitle": "Made with love in Gurugram",
          "style": { "foreground": "text.onDark" }
        }
        """)
        #expect(node.title == "better drives, better lives")
        #expect(node.subtitle == "Made with love in Gurugram")
        #expect(node.style?.foreground == Palette.textOnDark)
    }

    @Test
    func absentSubtitleAndStyleAreNil() throws {
        let node = try decode(TextBlockNode.self, """
        { "id": "x", "type": "textBlock", "title": "t" }
        """)
        #expect(node.subtitle == nil)
        #expect(node.style == nil)
    }

    @Test
    func missingMandatoryTitleThrows() {
        #expect(throws: (any Error).self) {
            try decode(TextBlockNode.self, "{ \"id\": \"x\", \"type\": \"textBlock\" }")
        }
    }
}
