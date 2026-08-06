//
//  ItemWidthTests.swift
//  SwiftUISDUITests
//
//  Executed tests for design_spec.md §2.6's item-width formula:
//  (availableWidth - 2*margin - gap*floor(ratio)) / ratio
//

import CoreGraphics
@testable import SwiftUISDUI
import Testing

struct ItemWidthTests {

    // availableWidth = 390 (design_spec.md §1 reference logical width),
    // gap = 12, margin = 8 (defaults, from Spacing).

    @Test
    func smResolvesUsingFormula() {
        let result = resolveItemWidth(.sm, availableWidth: 390)
        #expect(abs(result - (390 - 16 - 12 * 3) / 3.25) < 0.001)
    }

    @Test
    func mdResolvesUsingFormula() {
        let result = resolveItemWidth(.md, availableWidth: 390)
        #expect(abs(result - (390 - 16 - 12 * 2) / 2.5) < 0.001)
    }

    @Test
    func lgResolvesUsingFormula() {
        let result = resolveItemWidth(.lg, availableWidth: 390)
        #expect(abs(result - (390 - 16 - 12 * 1) / 1.6) < 0.001)
    }

    @Test
    func xlResolvesUsingFormula() {
        let result = resolveItemWidth(.xl, availableWidth: 390)
        #expect(abs(result - (390 - 16 - 12 * 1) / 1.3) < 0.001)
    }

    @Test
    func fullResolvesUsingFormula() {
        let result = resolveItemWidth(.full, availableWidth: 390)
        #expect(abs(result - (390 - 16 - 12 * 1) / 1.0) < 0.001)
    }

    @Test
    func defaultGapAndMarginMatchSpacingTokens() {
        #expect(resolveItemWidth(.md, availableWidth: 390)
                 == resolveItemWidth(.md, availableWidth: 390, gap: Spacing.railGap, margin: Spacing.pageMargin))
    }

    @Test(arguments: ["sm", "md", "lg", "xl", "full"])
    func rawValueRoundTripsForEveryPayloadString(_ raw: String) {
        #expect(ItemWidth(rawValue: raw)?.rawValue == raw)
    }
}
