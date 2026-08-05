//
//  SectionNode.swift
//  SwiftUISDUI
//
//  design_spec.md §3.1: `PageStore` holds `[SectionNode]`. A closed `enum`,
//  not the item registry's dictionary pattern — containers are a fixed set
//  of 5 (+ header), with no analogous "add a container" extension workflow
//  in ADDING_A_COMPONENT.md (that runbook is scoped to item types). This
//  does not conflict with CLAUDE.md's "no enum for the registry"
//  prohibition, which targets the item lookup specifically; section
//  dispatch is a plain `switch` on the decoded type string
//  (Decoding/SectionDecoding.swift), functionally a lookup either way.
//

nonisolated enum SectionNode: Identifiable {
    case header(HeaderSectionNode)
    case rail(RailNode)
    case grid(GridNode)
    case carousel(CarouselNode)
    case list(ListNode)
    case single(SingleNode)

    var id: String {
        switch self {
        case .header(let node): node.id
        case .rail(let node): node.id
        case .grid(let node): node.id
        case .carousel(let node): node.id
        case .list(let node): node.id
        case .single(let node): node.id
        }
    }
}
