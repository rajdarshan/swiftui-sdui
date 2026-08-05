//
//  ItemWidth.swift
//  SwiftUISDUI
//
//  Item width resolution. design_spec.md §2.6. Pure calculation only — the
//  @Environment plumbing that measures and injects availableWidth is added
//  in Stage 2 alongside the page container that consumes it.
//

import CoreGraphics

nonisolated enum ItemWidth: String {
    case sm, md, lg, xl, full

    var ratio: Double {
        switch self {
        case .sm: 3.25
        case .md: 2.5
        case .lg: 1.6
        case .xl: 1.3
        case .full: 1.0
        }
    }
}

func resolveItemWidth(
    _ token: ItemWidth,
    availableWidth: CGFloat,
    gap: CGFloat = Spacing.railGap,
    margin: CGFloat = Spacing.pageMargin
) -> CGFloat {
    let ratio = CGFloat(token.ratio)
    let width = (availableWidth - (2 * margin) - (gap * ratio.rounded(.down))) / ratio
    print("availableWidth: \(availableWidth), width: \(width)")
    return width
}
