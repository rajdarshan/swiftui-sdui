//
//  ItemDecoding.swift
//  SwiftUISDUI
//
//  design_spec.md §3.3 steps 2-4: look up `type` in the registry; hit → run
//  the decode closure; miss or throw → try `fallback` (one level only, and
//  the fallback must not itself declare a nested `fallback` —
//  COMPONENTS.md §10); still nothing → drop the item. `compactMap`-style
//  dropping happens naturally because `decodeItem` returns `nil` instead of
//  throwing — one bad item never aborts its container.
//
//  `nonisolated`: called from Decodable's nonisolated `init(from:)`
//  contexts throughout the section nodes (design_spec.md §3.3: unit
//  testable with no running app), while the module otherwise defaults
//  every declaration to @MainActor.
//

nonisolated func decodeItem(from decoder: Decoder) -> (any ItemNode)? {
    guard let registry = decoder.userInfo[.componentRegistry] as? ComponentRegistry,
          let raw = try? RawItemEnvelope(from: decoder) else {
        return nil
    }

    if let decode = registry.itemDecoders[raw.type], let node = try? decode(decoder) {
        return node
    }

    // Primary failed — either an unrecognized type, or a known type with a
    // malformed/missing mandatory prop. Both fall back the same way.
    guard let fallbackDecoder = raw.fallbackDecoder,
          let fallbackRaw = try? RawItemEnvelope(from: fallbackDecoder),
          fallbackRaw.fallbackDecoder == nil, // no nested fallback — COMPONENTS.md §10
          let fallbackDecode = registry.itemDecoders[fallbackRaw.type] else {
        return nil
    }
    return try? fallbackDecode(fallbackDecoder)
}

nonisolated enum ItemArray {
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> [any ItemNode] {
        var results: [any ItemNode] = []
        while !container.isAtEnd {
            let elementDecoder = try container.superDecoder()
            if let node = decodeItem(from: elementDecoder) {
                results.append(node)
            }
        }
        return results
    }
}
