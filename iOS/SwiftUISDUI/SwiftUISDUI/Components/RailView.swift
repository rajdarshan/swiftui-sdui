//
//  RailView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6 rail container. design_spec.md §4.1: ScrollView(.horizontal)
//  + LazyHStack(spacing: 12), .scrollTargetBehavior(.viewAligned) when snap.
//  Absent snap defaults to enabled (no stated default in the spec; see the
//  Stage 2 plan's scope decisions).
//

import SwiftUI

struct RailView<Item: Identifiable, ItemContent: View>: View {
    let items: [Item]
    let itemWidth: ItemWidth
    let snap: Bool
    let content: (Item) -> ItemContent

    @Environment(\.availableWidth) private var availableWidth

    init(
        items: [Item],
        itemWidth: ItemWidth,
        snap: Bool = true,
        @ViewBuilder content: @escaping (Item) -> ItemContent
    ) {
        self.items = items
        self.itemWidth = itemWidth
        self.snap = snap
        self.content = content
    }

    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: Spacing.railGap) {
                ForEach(items, id: \.id) { item in
                    content(item)
                        .containerRelativeFrame(.horizontal, count: items.count, span: 2, spacing: Spacing.railGap)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, Spacing.pageMargin)
        }
        .viewAligned(if: snap)
        .scrollIndicators(.hidden)
    }
}

private extension View {
    @ViewBuilder
    func viewAligned(if enabled: Bool) -> some View {
        if enabled {
            scrollTargetBehavior(.viewAligned)
        } else {
            self
        }
    }
}
