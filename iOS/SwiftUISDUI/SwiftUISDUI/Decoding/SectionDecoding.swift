//
//  SectionDecoding.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §10: unknown section type → section skipped, siblings
//  render. Sections have no `fallback` concept (only items do, §8), so
//  there's a single `try?` branch per case, not the two-step item
//  algorithm — the natural minimal extension of design_spec.md §3.3 to a
//  level with no fallback field. A known type with a missing mandatory
//  prop fails the same way, via the same `try?`.
//

private nonisolated struct RawSectionEnvelope: Decodable {
    let type: String
}

nonisolated func decodeSection(from decoder: Decoder) -> SectionNode? {
    guard let raw = try? RawSectionEnvelope(from: decoder) else { return nil }
    switch raw.type {
    case "header": return (try? HeaderSectionNode(from: decoder)).map(SectionNode.header)
    case "rail": return (try? RailNode(from: decoder)).map(SectionNode.rail)
    case "grid": return (try? GridNode(from: decoder)).map(SectionNode.grid)
    case "carousel": return (try? CarouselNode(from: decoder)).map(SectionNode.carousel)
    case "list": return (try? ListNode(from: decoder)).map(SectionNode.list)
    case "single": return (try? SingleNode(from: decoder)).map(SectionNode.single)
    default: return nil
    }
}
