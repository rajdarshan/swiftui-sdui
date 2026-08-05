//
//  PayloadDecoder.swift
//  SwiftUISDUI
//
//  Top-level entry point implementing design_spec.md §3.3's decode/fallback
//  algorithm end to end: thread the registry through `Decoder.userInfo`,
//  then let `PageEnvelope`'s own `init(from:)` walk sections (and, via
//  `decodeSection`/`decodeItem`, items) with fallback applied at every
//  level. Defaults to `ComponentRegistry.shared` — a caller can pass its
//  own for the "old-client" test (a registry missing a type entirely).
//

import Foundation

enum PayloadDecoder {
    static func decode(_ data: Data, registry: ComponentRegistry = .shared) throws -> PageEnvelope {
        let decoder = JSONDecoder()
        decoder.userInfo[.componentRegistry] = registry
        return try decoder.decode(PageEnvelope.self, from: data)
    }
}
