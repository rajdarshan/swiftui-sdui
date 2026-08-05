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
    let itemHeight: CGFloat
    let content: (Item) -> ItemContent

    @Environment(\.availableWidth) private var availableWidth

    init(
        items: [Item],
        itemWidth: ItemWidth,
        snap: Bool = true,
        itemHeight: CGFloat = 120,
        @ViewBuilder content: @escaping (Item) -> ItemContent
    ) {
        self.items = items
        self.itemWidth = itemWidth
        self.snap = snap
        self.content = content
        self.itemHeight = itemHeight
    }

    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Spacing.railGap) {
                ForEach(items, id: \.id) { item in
                    content(item)
                        .frame(height: itemHeight)
                }
            }
            .padding(.horizontal, Spacing.pageMargin)
            .scrollTargetLayout()
        }
        .viewAligned(if: snap)
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
