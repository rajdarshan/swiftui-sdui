//
//  CarouselView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6 carousel container. design_spec.md §4.3: hand-rolled on
//  ScrollView(.horizontal) + .scrollTargetBehavior(.viewAligned) +
//  .scrollPosition(id:). No TabView(.page) here — prohibited outside
//  placeCard's image pager.
//
//  Card width: no numeric peek value exists anywhere in the text spec, so
//  this reuses the existing itemWidth ratio system rather than inventing a
//  new number (Stage 2 plan's scope decisions): peek ? .xl : .full.
//
//  loop: true prepends/appends buffer copies (sentinel ids "buffer-leading"/
//  "buffer-trailing") and snaps back to the matching real item without
//  animation on landing. Exactly 2 items duplicates the second per
//  COMPONENTS.md §6, with no boundary-reset needed for that small case.
//  autoScrollMs is deferred (Stage 2 plan's scope decisions) — position is
//  static until manually scrolled.
//

import SwiftUI

struct CarouselView<Item: Identifiable, ItemContent: View>: View {
    let items: [Item]
    let loop: Bool
    let peek: Bool
    let content: (Item) -> ItemContent

    @Environment(\.availableWidth) private var availableWidth
    @State private var scrollPosition: String?

    init(
        items: [Item],
        loop: Bool = false,
        peek: Bool = false,
        @ViewBuilder content: @escaping (Item) -> ItemContent
    ) {
        self.items = items
        self.loop = loop
        self.peek = peek
        self.content = content
    }

    private struct WrappedItem: Identifiable {
        let id: String
        let item: Item
    }

    private var displayItems: [WrappedItem] {
        let wrapped = items.map { WrappedItem(id: "\($0.id)", item: $0) }
        guard loop, items.count > 1 else { return wrapped }
        if items.count == 2 {
            return wrapped + [WrappedItem(id: "buffer-trailing", item: items[1])]
        }
        guard let first = items.first, let last = items.last else { return wrapped }
        let leading = WrappedItem(id: "buffer-leading", item: last)
        let trailing = WrappedItem(id: "buffer-trailing", item: first)
        return [leading] + wrapped + [trailing]
    }

    private var cardWidth: CGFloat {
        resolveItemWidth(peek ? .xl : .full, availableWidth: availableWidth)
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: Spacing.railGap) {
                ForEach(displayItems, id: \.id) { wrapped in
                    content(wrapped.item)
                        .frame(width: cardWidth)
                        .id(wrapped.id)
                }
            }
            .padding(.horizontal, Spacing.pageMargin)
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .onAppear(perform: resetToStart)
        .onChange(of: scrollPosition) { _, _ in resetAtBoundary() }
    }

    private func resetToStart() {
        guard loop, items.count > 2, let firstReal = items.first else { return }
        scrollPosition = "\(firstReal.id)"
    }

    private func resetAtBoundary() {
        guard loop, items.count > 2 else { return }
        if scrollPosition == "buffer-trailing", let first = items.first {
            snap(to: "\(first.id)")
        } else if scrollPosition == "buffer-leading", let last = items.last {
            snap(to: "\(last.id)")
        }
    }

    private func snap(to id: String) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            scrollPosition = id
        }
    }
}
