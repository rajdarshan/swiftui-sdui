//
//  TokenResolutionTests.swift
//  SwiftUISDUITests
//
//  Executed tests for COMPONENTS.md §10: "Unknown token → client default
//  substituted." Resolvers return nil on an unrecognized token — the
//  default is applied at each call site, not inside the resolver.
//

@testable import SwiftUISDUI
import Testing

struct PaletteResolveTests {

    @Test
    func knownTokenResolvesToTheMatchingConstant() {
        #expect(Palette.resolve("tile.blue") == Palette.tileBlue)
        #expect(Palette.resolve("brand.primary") == Palette.brandPrimary)
        #expect(Palette.resolve("text.onDark") == Palette.textOnDark)
        #expect(Palette.resolve("badge.danger") == Palette.badgeDanger)
    }

    @Test
    func unknownTokenResolvesToNil() {
        #expect(Palette.resolve("tile.magenta") == nil)
        #expect(Palette.resolve("") == nil)
    }
}

struct RadiusResolveTests {

    @Test
    func knownTokenResolvesToTheMatchingConstant() {
        #expect(Radius.resolve("none") == Radius.none)
        #expect(Radius.resolve("sm") == Radius.sm)
        #expect(Radius.resolve("md") == Radius.md)
        #expect(Radius.resolve("lg") == Radius.lg)
        #expect(Radius.resolve("pill") == Radius.pill)
    }

    @Test
    func unknownTokenResolvesToNil() {
        #expect(Radius.resolve("xl") == nil)
    }
}

struct IconTokenResolveTests {

    @Test
    func knownTokenResolvesToTheMatchingSymbolName() {
        #expect(IconToken.resolve("grid") == IconToken.grid)
        #expect(IconToken.resolve("heart") == IconToken.heart)
        #expect(IconToken.resolve("person") == IconToken.person)
    }

    @Test
    func unknownTokenResolvesToNil() {
        #expect(IconToken.resolve("rocket") == nil)
    }
}
