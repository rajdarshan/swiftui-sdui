//
//  TileView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, image O, style O, action M.
//  design_spec.md §4.4: ZStack, title top-leading, image bottom-trailing,
//  clipShape(RoundedRectangle). Image may overflow the tile edge — clip.
//  design_spec.md §2.5: tile height 84.
//
//  Whole-card tap dispatches `action` through the environment-injected
//  ActionHandler (design_spec.md §3.2 rule 4). Default handler is a no-op,
//  so the static screen (which never injects one) stays inert with no
//  special-casing here.
//

import SwiftUI

struct TileView: View {
    let title: String
    let image: ImageRef?
    let style: Style?
    let action: Action
    let imageName: String?

    private var cornerRadius: CGFloat { style?.cornerRadius ?? Radius.lg }
    @Environment(\.useImageAsset) private var useImageAsset
    @Environment(\.actionHandler) private var actionHandler

    var body: some View {
        ZStack(alignment: .topLeading) {
            style?.background ?? Palette.surfaceMuted
            
            if useImageAsset, let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else if let image {
                CachedImage(imageRef: image)
                    .frame(width: 120, height: 100)
            }
            
            Text(title)
                .font(Typography.cardTitle)
                .foregroundStyle(style?.foreground ?? Palette.textPrimary)
                .lineLimit(2, reservesSpace: true)
                .truncationMode(.tail)
                .padding(Spacing.tilePadding)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onTapGesture { actionHandler.handle(action) }
    }
}
