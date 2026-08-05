//
//  DuplicateItemIdResolution.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §10: "Duplicate item id within a page | Decoder logs; last
//  occurrence wins." Item ids only need to be unique page-scoped (§8), so
//  this walks the whole decoded section tree — not per-container — and
//  drops every occurrence of a repeated id except the last one in document
//  order. A `single.item` is never dropped (it has nowhere to fall back
//  to — dropping it would leave the section with no mandatory item at
//  all), but it still counts toward the running total so a rail item
//  sharing its id is correctly treated as the earlier, droppable one.
//
//  Two passes: first count total occurrences per id across the page, then
//  walk again keeping an item only once its running count matches the
//  total (i.e. this occurrence is the last one).
//

private nonisolated func itemIds(items: [any ItemNode]?, filter: FilterNode?) -> [String] {
    if let filter {
        return filter.chips.flatMap { $0.items.map(\.id) }
    }
    return items?.map(\.id) ?? []
}

private nonisolated func itemIds(in section: SectionNode) -> [String] {
    switch section {
    case .header:
        return []
    case .rail(let node):
        return itemIds(items: node.items, filter: node.filter)
    case .grid(let node):
        return itemIds(items: node.items, filter: node.filter)
    case .carousel(let node):
        return node.items.map(\.id)
    case .list(let node):
        return itemIds(items: node.items, filter: node.filter)
    case .single(let node):
        return [node.item.id]
    }
}

private nonisolated func isLastOccurrence(_ id: String, totalCounts: [String: Int], runningCounts: inout [String: Int]) -> Bool {
    runningCounts[id, default: 0] += 1
    let isLast = runningCounts[id] == totalCounts[id]
    if !isLast {
        print("[PayloadDecoder] duplicate item id \"\(id)\" — dropping earlier occurrence, last wins")
    }
    return isLast
}

private nonisolated func dedupFilter(_ filter: FilterNode?, totalCounts: [String: Int], runningCounts: inout [String: Int]) -> FilterNode? {
    guard let filter else { return nil }
    let dedupedChips = filter.chips.map { chip -> ChipNode in
        let items = chip.items.filter { isLastOccurrence($0.id, totalCounts: totalCounts, runningCounts: &runningCounts) }
        return ChipNode(id: chip.id, label: chip.label, items: items)
    }
    return FilterNode(defaultChipId: filter.defaultChipId, chips: dedupedChips)
}

private nonisolated func dedupSection(_ section: SectionNode, totalCounts: [String: Int], runningCounts: inout [String: Int]) -> SectionNode {
    func keep(_ id: String) -> Bool {
        isLastOccurrence(id, totalCounts: totalCounts, runningCounts: &runningCounts)
    }
    func dedupItems(_ items: [any ItemNode]?) -> [any ItemNode]? {
        items?.filter { keep($0.id) }
    }

    switch section {
    case .header:
        return section
    case .rail(let node):
        return .rail(RailNode(
            id: node.id, header: node.header, style: node.style,
            filter: dedupFilter(node.filter, totalCounts: totalCounts, runningCounts: &runningCounts),
            items: dedupItems(node.items), itemWidth: node.itemWidth, snap: node.snap
        ))
    case .grid(let node):
        return .grid(GridNode(
            id: node.id, header: node.header, style: node.style,
            filter: dedupFilter(node.filter, totalCounts: totalCounts, runningCounts: &runningCounts),
            items: dedupItems(node.items), columns: node.columns
        ))
    case .carousel(let node):
        return .carousel(CarouselNode(
            id: node.id, header: node.header, style: node.style,
            items: node.items.filter { keep($0.id) },
            loop: node.loop, peek: node.peek, autoScrollMs: node.autoScrollMs
        ))
    case .list(let node):
        return .list(ListNode(
            id: node.id, header: node.header, style: node.style,
            filter: dedupFilter(node.filter, totalCounts: totalCounts, runningCounts: &runningCounts),
            items: dedupItems(node.items)
        ))
    case .single(let node):
        _ = keep(node.item.id)
        return section
    }
}

nonisolated func deduplicatingItemIds(in sections: [SectionNode]) -> [SectionNode] {
    let totalCounts = Dictionary(
        sections.flatMap { itemIds(in: $0) }.map { ($0, 1) },
        uniquingKeysWith: +
    )
    guard totalCounts.values.contains(where: { $0 > 1 }) else { return sections }

    var runningCounts: [String: Int] = [:]
    return sections.map { dedupSection($0, totalCounts: totalCounts, runningCounts: &runningCounts) }
}
