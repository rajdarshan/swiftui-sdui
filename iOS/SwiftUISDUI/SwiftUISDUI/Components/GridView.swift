//
//  GridView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6 grid container, fixed 2-4 columns. design_spec.md §4.1:
//  VStack + HStack rows, not the lazy-vertical-grid API — fixed item count,
//  no benefit, known sizing quirks inside a lazy parent. Equal row heights
//  via .fixedSize(horizontal:false, vertical:true).
//

import SwiftUI

struct GridView<Item: Identifiable, ItemContent: View>: View {
    let items: [Item]
    let columns: Int
    let content: (Item) -> ItemContent

    private var rows: [[Item]] {
        stride(from: 0, to: items.count, by: columns).map {
            Array(items[$0..<min($0 + columns, items.count)])
        }
    }

    var body: some View {
        VStack(spacing: Spacing.gridGutter) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: Spacing.gridGutter) {
                    ForEach(row, id: \.id) { item in
                        content(item)
                            .frame(maxWidth: .infinity)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
    }
}
