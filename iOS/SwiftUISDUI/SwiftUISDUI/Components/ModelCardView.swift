//
//  ModelCardView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, image M, subtitle O, watermark O, style O,
//  action M.
//  design_spec.md §4.4: ZStack, watermark digit behind image, text.secondary
//  at ~0.25 opacity, large. Title/subtitle top-leading.
//
//  Whole-card tap dispatches `action` through the environment-injected
//  ActionHandler (design_spec.md §3.2 rule 4) — inert by default, matching
//  the static screen.
//

import SwiftUI

struct ModelCardView: View {
    let title: String
    let image: ImageRef
    let subtitle: String?
    let watermark: String?
    let style: Style?
    let action: Action

    @Environment(\.actionHandler) private var actionHandler

    var body: some View {
        ZStack(alignment: .topLeading) {
            style?.background ?? Palette.surfaceMuted

            if let watermark {
                Text(watermark)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(Palette.textSecondary.opacity(0.25))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.leading, Spacing.cardPadding)
            }

            CachedImage(imageRef: image)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.cardTitle)
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(Typography.cardSubtitle)
                        .foregroundStyle(Palette.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(Spacing.cardPadding)
        }
        .clipShape(RoundedRectangle(cornerRadius: style?.cornerRadius ?? Radius.lg))
        .onTapGesture { actionHandler.handle(action) }
    }
}
