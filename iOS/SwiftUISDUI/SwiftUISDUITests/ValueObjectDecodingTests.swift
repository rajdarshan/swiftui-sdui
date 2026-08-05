//
//  ValueObjectDecodingTests.swift
//  SwiftUISDUITests
//
//  Executed tests for the six shared value objects' Decodable conformance:
//  COMPONENTS.md §4.1 (Action), §4.2 (ImageRef), §4.3 (Badge), §4.4 (Button),
//  §4.5 (Style), §4.6 (Header/SectionHeader). Covers happy path, every
//  optional-absent default, and unknown-token/unknown-enum-value defaulting
//  per §10 and §2.1.
//

import Foundation
@testable import SwiftUISDUI
import Testing

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try JSONDecoder().decode(type, from: Data(json.utf8))
}

struct ActionDecodingTests {

    @Test
    func decodesWithParams() throws {
        let action = try decode(Action.self, """
        { "type": "navigate", "target": "listing", "params": { "filter": "budget" } }
        """)
        #expect(action == Action(type: "navigate", target: "listing", params: ["filter": "budget"]))
    }

    @Test
    func absentParamsDefaultsToEmpty() throws {
        let action = try decode(Action.self, """
        { "type": "search", "target": "search" }
        """)
        #expect(action == Action(type: "search", target: "search"))
    }

    @Test
    func unrecognizedActionTypeDecodesVerbatim() throws {
        // COMPONENTS.md §10: unknown action.type → node renders, tap is a
        // no-op. Decoding never rejects it — dispatch-miss is a Stage 4
        // ActionHandler concern.
        let action = try decode(Action.self, """
        { "type": "select", "target": "used_cars_rail", "params": { "datasetId": "hot_deals" } }
        """)
        #expect(action.type == "select")
    }
}

struct BadgeDecodingTests {

    @Test
    func decodesWithIconAndVariant() throws {
        let badge = try decode(Badge.self, """
        { "text": "Up to \\u20b980,000 off", "icon": "shield", "variant": "danger" }
        """)
        #expect(badge.text == "Up to \u{20b9}80,000 off")
        #expect(badge.icon == IconToken.shield)
        #expect(badge.variant == .danger)
    }

    @Test
    func absentIconAndVariantUseDefaults() throws {
        let badge = try decode(Badge.self, """
        { "text": "90+ cars" }
        """)
        #expect(badge.icon == nil)
        #expect(badge.variant == .neutral)
    }

    @Test
    func unknownIconOmitsIconTextStays() throws {
        let badge = try decode(Badge.self, """
        { "text": "New", "icon": "rocket" }
        """)
        #expect(badge.icon == nil)
        #expect(badge.text == "New")
    }

    @Test
    func unknownVariantFallsBackToNeutral() throws {
        let badge = try decode(Badge.self, """
        { "text": "New", "variant": "sparkly" }
        """)
        #expect(badge.variant == .neutral)
    }
}

struct ButtonSpecDecodingTests {

    @Test
    func absentVariantDefaultsToFilled() throws {
        let spec = try decode(ButtonSpec.self, """
        { "text": "Call us now", "action": { "type": "call", "target": "+918001234567" } }
        """)
        #expect(spec.variant == .filled)
        #expect(spec.leadingIcon == nil)
    }

    @Test
    func unknownVariantFallsBackToFilled() throws {
        let spec = try decode(ButtonSpec.self, """
        { "text": "Call us now", "action": { "type": "call", "target": "x" }, "variant": "glowing" }
        """)
        #expect(spec.variant == .filled)
    }

    @Test
    func leadingIconResolvesKnownToken() throws {
        let spec = try decode(ButtonSpec.self, """
        { "text": "Call us now", "action": { "type": "call", "target": "x" }, "leadingIcon": "phone" }
        """)
        #expect(spec.leadingIcon == IconToken.phone)
    }
}

struct ImageRefDecodingTests {

    @Test
    func decodesUrlAspectAndKnownPlaceholder() throws {
        let ref = try decode(ImageRef.self, """
        { "url": "https://placehold.co/1x1", "placeholder": "surface.chip", "aspect": 1.5 }
        """)
        #expect(ref.url == "https://placehold.co/1x1")
        #expect(ref.placeholder == Palette.surfaceChip)
        #expect(ref.aspect == 1.5)
    }

    @Test
    func absentPlaceholderDefaultsToSurfaceMuted() throws {
        let ref = try decode(ImageRef.self, """
        { "url": "https://placehold.co/1x1" }
        """)
        #expect(ref.placeholder == Palette.surfaceMuted)
        #expect(ref.aspect == nil)
    }

    @Test
    func unknownPlaceholderDefaultsToSurfaceMuted() throws {
        let ref = try decode(ImageRef.self, """
        { "url": "https://placehold.co/1x1", "placeholder": "surface.rainbow" }
        """)
        #expect(ref.placeholder == Palette.surfaceMuted)
    }
}

struct StyleDecodingTests {

    @Test
    func decodesAllKnownTokens() throws {
        let style = try decode(Style.self, """
        { "background": "tile.blue", "foreground": "text.onDark", "border": "tile.creamBorder", "cornerRadius": "lg" }
        """)
        #expect(style.background == Palette.tileBlue)
        #expect(style.foreground == Palette.textOnDark)
        #expect(style.border == Palette.tileCreamBorder)
        #expect(style.cornerRadius == Radius.lg)
    }

    @Test
    func allAbsentResolvesToAllNil() throws {
        let style = try decode(Style.self, "{}")
        #expect(style.background == nil)
        #expect(style.foreground == nil)
        #expect(style.border == nil)
        #expect(style.cornerRadius == nil)
    }

    @Test
    func unknownTokensResolveToNil() throws {
        let style = try decode(Style.self, """
        { "background": "brand.rainbow", "cornerRadius": "huge" }
        """)
        #expect(style.background == nil)
        #expect(style.cornerRadius == nil)
    }
}

struct SectionHeaderDecodingTests {

    @Test
    func decodesWithBadgeAndTrailing() throws {
        let header = try decode(SectionHeader.self, """
        {
          "title": "Buy car",
          "badge": { "text": "Up to 80,000 off", "variant": "danger" },
          "trailing": { "text": "View all", "action": { "type": "navigate", "target": "listing" }, "variant": "ghost" }
        }
        """)
        #expect(header.title == "Buy car")
        #expect(header.badge?.variant == .danger)
        #expect(header.trailing?.variant == .ghost)
    }

    @Test
    func absentBadgeAndTrailingAreNil() throws {
        let header = try decode(SectionHeader.self, """
        { "title": "Sell your car" }
        """)
        #expect(header.badge == nil)
        #expect(header.trailing == nil)
    }
}
