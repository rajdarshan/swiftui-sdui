//
//  EnumRawValueTests.swift
//  SwiftUISDUITests
//
//  Executed tests confirming the closed-vocabulary enums used by decoded
//  item props round-trip through their COMPONENTS.md wire-format string
//  exactly. Raw-value backing is what lets a decoder go
//  `Badge.Variant(rawValue:)` against the payload string directly.
//

@testable import SwiftUISDUI
import Testing

struct BadgeVariantRawValueTests {
    @Test(arguments: ["neutral", "accent", "success", "warning", "danger"])
    func rawValueRoundTripsForEveryPayloadString(_ raw: String) {
        #expect(Badge.Variant(rawValue: raw)?.rawValue == raw)
    }
}

struct ButtonSpecVariantRawValueTests {
    @Test(arguments: ["filled", "outline", "ghost"])
    func rawValueRoundTripsForEveryPayloadString(_ raw: String) {
        #expect(ButtonSpec.Variant(rawValue: raw)?.rawValue == raw)
    }
}

struct IconTileImageShapeRawValueTests {
    @Test(arguments: ["circle", "arch", "square"])
    func rawValueRoundTripsForEveryPayloadString(_ raw: String) {
        #expect(IconTileImageShape(rawValue: raw)?.rawValue == raw)
    }
}

struct FeatureCardImagePositionRawValueTests {
    @Test(arguments: ["leading", "top"])
    func rawValueRoundTripsForEveryPayloadString(_ raw: String) {
        #expect(FeatureCardImagePosition(rawValue: raw)?.rawValue == raw)
    }
}
