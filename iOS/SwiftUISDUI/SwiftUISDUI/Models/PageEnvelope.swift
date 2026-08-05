//
//  PageEnvelope.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §3: `schemaVersion`/`version`/`pageId` M strings, `sections`
//  M ordered array (empty is valid). `schemaVersion` is stored and never
//  inspected for gating (design_spec.md §3.2 rule 7) — a malformed envelope
//  itself (missing id/version/pageId) is a hard failure that propagates to
//  the caller, not a per-node fallback case; only individual sections
//  degrade via `decodeSection`'s `try?`.
//

struct PageEnvelope: Decodable {
    let schemaVersion: String
    let version: String
    let pageId: String
    let sections: [SectionNode]

    private enum CodingKeys: String, CodingKey { case schemaVersion, version, pageId, sections }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        version = try container.decode(String.self, forKey: .version)
        pageId = try container.decode(String.self, forKey: .pageId)

        var sectionsContainer = try container.nestedUnkeyedContainer(forKey: .sections)
        var decodedSections: [SectionNode] = []
        while !sectionsContainer.isAtEnd {
            let elementDecoder = try sectionsContainer.superDecoder()
            if let section = decodeSection(from: elementDecoder) {
                decodedSections.append(section)
            }
        }
        sections = decodedSections
    }
}
