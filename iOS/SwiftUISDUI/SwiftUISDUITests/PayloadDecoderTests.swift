//
//  PayloadDecoderTests.swift
//  SwiftUISDUITests
//
//  Executed tests for the top-level entry point (COMPONENTS.md §3
//  envelope). Full fallback-demo-payload coverage and the old-client
//  regression test land in a later commit — this covers the envelope
//  itself: mandatory fields, empty sections being valid, and a minimal
//  multi-section decode.
//

import Foundation
@testable import SwiftUISDUI
import Testing

struct PayloadDecoderTests {

    // mirrors sdui-config/payloads/home_loans.json's shape (header + one single/textBlock)
    @Test
    func decodesAMinimalTwoSectionPayload() throws {
        let data = Data("""
        {
          "schemaVersion": "1.0", "version": "1.0.0", "pageId": "home_loans",
          "sections": [
            {
              "id": "app_header", "type": "header",
              "search": { "placeholders": [], "action": { "type": "search", "target": "search" } },
              "tabs": { "selectedId": "loans", "items": [] }
            },
            {
              "id": "home_loans_placeholder", "type": "single",
              "item": { "id": "home_loans_placeholder__x", "type": "textBlock", "title": "Loans", "subtitle": "Coming soon" }
            }
          ]
        }
        """.utf8)
        let envelope = try PayloadDecoder.decode(data)
        #expect(envelope.schemaVersion == "1.0")
        #expect(envelope.version == "1.0.0")
        #expect(envelope.pageId == "home_loans")
        #expect(envelope.sections.count == 2)
        #expect(envelope.sections.map(\.id) == ["app_header", "home_loans_placeholder"])
    }

    @Test
    func emptySectionsArrayIsValid() throws {
        let data = Data("""
        { "schemaVersion": "1.0", "version": "1.0.0", "pageId": "empty", "sections": [] }
        """.utf8)
        let envelope = try PayloadDecoder.decode(data)
        #expect(envelope.sections.isEmpty)
    }

    @Test
    func missingMandatoryPageIdThrows() {
        let data = Data("""
        { "schemaVersion": "1.0", "version": "1.0.0", "sections": [] }
        """.utf8)
        #expect(throws: (any Error).self) {
            try PayloadDecoder.decode(data)
        }
    }

    @Test
    func unknownSectionTypeIsSkippedSiblingsSurvive() throws {
        let data = Data("""
        {
          "schemaVersion": "1.0", "version": "1.0.0", "pageId": "x",
          "sections": [
            { "id": "unknown_section", "type": "storyReel", "items": [] },
            {
              "id": "single_section", "type": "single",
              "item": { "id": "y", "type": "textBlock", "title": "t" }
            }
          ]
        }
        """.utf8)
        let envelope = try PayloadDecoder.decode(data)
        #expect(envelope.sections.map(\.id) == ["single_section"])
    }
}
