//
//  TileView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, image O, style O, action M.
//  design_spec.md §4.4: ZStack, title top-leading, image bottom-trailing,
//  clipShape(RoundedRectangle). Image may overflow the tile edge — clip.
//  design_spec.md §2.5: tile height 84.
//

import SwiftUI

struct TileView: View {
    let title: String
    let image: ImageRef?
    let style: Style?
    let action: Action

    private var cornerRadius: CGFloat { style?.cornerRadius ?? Radius.lg }

    var body: some View {
        ZStack(alignment: .topLeading) {
            style?.background ?? Palette.surfaceMuted

            if let image {
                CachedImage(imageRef: image)
                    .frame(width: 120, height: 100)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }

            Text(title)
                .font(Typography.cardTitle)
                .foregroundStyle(style?.foreground ?? Palette.textPrimary)
                .lineLimit(2)
                .truncationMode(.tail)
                .padding(Spacing.tilePadding)
        }
        .frame(height: 84)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(style?.border ?? .clear)
        )
        .onTapGesture {}
    }
}
