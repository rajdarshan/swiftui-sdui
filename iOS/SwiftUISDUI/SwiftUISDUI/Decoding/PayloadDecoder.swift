//
//  PayloadDecoder.swift
//  SwiftUISDUI
//
//  Top-level entry point implementing design_spec.md §3.3's decode/fallback
//  algorithm end to end: thread the registry through `Decoder.userInfo`,
//  then let `PageEnvelope`'s own `init(from:)` walk sections (and, via
//  `decodeSection`/`decodeItem`, items) with fallback applied at every
//  level, and finally resolve page-scoped duplicate item ids (COMPONENTS.md
//  §10) across the whole decoded tree. Defaults to `ComponentRegistry.shared`
//  — a caller can pass its own for the "old-client" test (a registry
//  missing a type entirely).
//

//
//  `nonisolated`: called from BundlePayloadSource's nonisolated async
//  `loadPage(pageId:)` (design_spec.md §3.1), while the module otherwise
//  defaults every declaration to @MainActor.
//

import Foundation

nonisolated enum PayloadDecoder {
    static func decode(_ data: Data, registry: ComponentRegistry = .shared) throws -> PageEnvelope {
        let decoder = JSONDecoder()
        decoder.userInfo[.componentRegistry] = registry
        let envelope = try decoder.decode(PageEnvelope.self, from: data)
        return PageEnvelope(
            schemaVersion: envelope.schemaVersion,
            version: envelope.version,
            pageId: envelope.pageId,
            sections: deduplicatingItemIds(in: envelope.sections)
        )
    }
}
