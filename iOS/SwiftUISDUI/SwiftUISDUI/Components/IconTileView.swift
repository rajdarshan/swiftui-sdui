//
//  IconTileView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: label M, image M, imageShape O (circle/arch/square),
//  action M.
//  design_spec.md §4.4: VStack, arch shape = UnevenRoundedRectangle with
//  large top radii, square bottom. Label below, 2 lines, centred.
//  design_spec.md §2.5: iconTile image 92 square.
//
//  Whole-tile tap dispatches `action` through the environment-injected
//  ActionHandler (design_spec.md §3.2 rule 4) — inert by default, matching
//  the static screen.
//

import SwiftUI

enum IconTileImageShape: String {
    case circle, arch, square
}

struct IconTileView: View {
    let label: String
    let image: ImageRef
    let imageShape: IconTileImageShape
    let action: Action
    let imageName: String
    @Environment(\.useImageAsset) private var useImageAsset
    @Environment(\.actionHandler) private var actionHandler

    init(label: String, image: ImageRef, imageShape: IconTileImageShape = .square, imageName: String, action: Action) {
        self.label = label
        self.image = image
        self.imageShape = imageShape
        self.action = action
        self.imageName = imageName
    }

    var body: some View {
        VStack(spacing: Spacing.sectionHeaderToContent) {
            if useImageAsset {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
//                    .frame(width: 120, height: 100)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            } else {
                CachedImage(imageRef: image)
                    .frame(width: 92, height: 92)
                    .clipShape(shape)
            }

            Text(label)
                .font(Typography.cardSubtitle)
                .foregroundStyle(Palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .truncationMode(.tail)
        }
        .onTapGesture { actionHandler.handle(action) }
    }

    private var shape: AnyShape {
        switch imageShape {
        case .circle:
            AnyShape(Circle())
        case .arch:
            AnyShape(UnevenRoundedRectangle(
                topLeadingRadius: Radius.pill,
                bottomLeadingRadius: Radius.none,
                bottomTrailingRadius: Radius.none,
                topTrailingRadius: Radius.pill
            ))
        case .square:
            AnyShape(RoundedRectangle(cornerRadius: Radius.md))
        }
    }
}
