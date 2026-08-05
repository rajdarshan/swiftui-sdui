//
//  RawItemEnvelope.swift
//  SwiftUISDUI
//
//  design_spec.md §3.3 step 1: decode each item element into a raw wrapper
//  exposing `type`, `id`, and (when present) a fresh `Decoder` over its
//  sibling `fallback` node — one level only, COMPONENTS.md §8/§10. The
//  wrapper hands its *original* `Decoder` back out via `decodeItem` so a
//  registry decode closure can build its own keyed container from it;
//  `superDecoder(forKey:)` is what makes that safe to do twice.
//

nonisolated struct RawItemEnvelope: Decodable {
    let id: String
    let type: String
    let fallbackDecoder: Decoder?

    private enum CodingKeys: String, CodingKey { case id, type, fallback }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        fallbackDecoder = container.contains(.fallback) ? try container.superDecoder(forKey: .fallback) : nil
    }
}
