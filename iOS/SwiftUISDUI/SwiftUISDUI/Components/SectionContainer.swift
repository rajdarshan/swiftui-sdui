//
//  SectionContainer.swift
//  SwiftUISDUI
//
//  Shared wrapper for every section type: optional SectionHeader above the
//  content, optional style.background painting the whole band.
//  COMPONENTS.md §6.
//

import SwiftUI

struct SectionContainer<Content: View>: View {
    let header: SectionHeader?
    let style: Style?
    let content: Content

    init(header: SectionHeader? = nil, style: Style? = nil, @ViewBuilder content: () -> Content) {
        self.header = header
        self.style = style
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
            if let header {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.sectionHeaderToContent) {
                    Text(header.title)
                        .font(Typography.sectionTitle)
                        .foregroundStyle(style?.background == nil ? Palette.textPrimary : Palette.textOnDark)
                    if let badge = header.badge {
                        BadgeView(badge: badge)
                    }
                    Spacer()
                    if let trailing = header.trailing {
                        ButtonSpecView(spec: trailing)
                    }
                }
                .padding(.horizontal, Spacing.pageMargin)
            }
            content
        }
        .padding(.vertical, Spacing.sectionHeaderToContent)
        .background(style?.background ?? .clear)
    }
}
