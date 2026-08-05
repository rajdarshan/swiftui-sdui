//
//  TextBlockView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, subtitle O, style O — no action.
//  design_spec.md §4.4: VStack, leading-aligned, generous vertical padding.
//

import SwiftUI

struct TextBlockView: View {
    let title: String
    let subtitle: String?
    let style: Style?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
            Text(title)
                .font(Typography.display)
                .foregroundStyle(style?.foreground ?? Palette.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(Typography.body)
                    .foregroundStyle(style?.foreground ?? Palette.textPrimary)
            }
        }
        .padding(.vertical, Spacing.sectionGap)
        .padding(.horizontal, Spacing.pageMargin)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
