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

import SwiftUI

enum IconTileImageShape {
    case circle, arch, square
}

struct IconTileView: View {
    let label: String
    let image: ImageRef
    let imageShape: IconTileImageShape
    let action: Action

    init(label: String, image: ImageRef, imageShape: IconTileImageShape = .square, action: Action) {
        self.label = label
        self.image = image
        self.imageShape = imageShape
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.sectionHeaderToContent) {
            CachedImage(imageRef: image)
                .frame(width: 92, height: 92)
                .clipShape(shape)

            Text(label)
                .font(Typography.cardSubtitle)
                .foregroundStyle(Palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .truncationMode(.tail)
        }
        .onTapGesture {}
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
