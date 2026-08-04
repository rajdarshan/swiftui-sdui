//
//  PaletteTests.swift
//  SwiftUISDUITests
//
//  Executed tests for Palette's hex parsing. design_spec.md §2.1 hex values
//  are transcribed with a leading "#" — this guards against the parser
//  silently discarding the "#" and resolving every token to black.
//

import CoreGraphics
import SwiftUI
@testable import SwiftUISDUI
import Testing
import UIKit

private struct ResolvedRGB {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
}

private func components(of color: Color) -> ResolvedRGB {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return ResolvedRGB(red: red, green: green, blue: blue)
}

struct PaletteTests {

    @Test
    func brandPrimaryMatchesHex382BC3() {
        let resolved = components(of: Palette.brandPrimary)
        #expect(abs(resolved.red - Double(0x38) / 255) < 0.01)
        #expect(abs(resolved.green - Double(0x2B) / 255) < 0.01)
        #expect(abs(resolved.blue - Double(0xC3) / 255) < 0.01)
    }

    @Test
    func tileOrangeMatchesHexC2410C() {
        let resolved = components(of: Palette.tileOrange)
        #expect(abs(resolved.red - Double(0xC2) / 255) < 0.01)
        #expect(abs(resolved.green - Double(0x41) / 255) < 0.01)
        #expect(abs(resolved.blue - Double(0x0C) / 255) < 0.01)
    }

    @Test
    func surfaceDefaultIsWhiteNotBlack() {
        let resolved = components(of: Palette.surfaceDefault)
        #expect(resolved.red > 0.99 && resolved.green > 0.99 && resolved.blue > 0.99)
    }
}
