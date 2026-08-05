//
//  FeatureCardView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, body O, image O, imagePosition O
//  (leading/top), badge O, footer O {text, trailingIcon?, action}. No
//  top-level action — only the footer link is tappable.
//  design_spec.md §4.4: HStack, image leading at fixed width, text trailing.
//  Dashed Divider above the footer row.
//
//  Swift parameter is `bodyText`, not `body` — that name is reserved by the
//  View protocol's own `body` property.
//
//  `footer` dispatches its `action` through the environment-injected
//  ActionHandler (design_spec.md §3.2 rule 4) — inert by default, matching
//  the static screen.
//

import SwiftUI

enum FeatureCardImagePosition: String {
    case leading, top
}

struct FeatureCardFooter {
    let text: String
    let trailingIcon: String?
    let action: Action

    init(text: String, trailingIcon: String? = nil, action: Action) {
        self.text = text
        self.trailingIcon = trailingIcon
        self.action = action
    }
}

private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

struct FeatureCardView: View {
    let title: String
    let bodyText: String?
    let image: ImageRef?
    let imagePosition: FeatureCardImagePosition
    let badge: Badge?
    let footer: FeatureCardFooter?
    let imageName: String?

    @Environment(\.actionHandler) private var actionHandler
    @Environment(\.useImageAsset) private var useImageAsset

    init(
        title: String,
        bodyText: String? = nil,
        image: ImageRef? = nil,
        imagePosition: FeatureCardImagePosition = .leading,
        badge: Badge? = nil,
        footer: FeatureCardFooter? = nil,
        imageName: String?
    ) {
        self.title = title
        self.bodyText = bodyText
        self.image = image
        self.imagePosition = imagePosition
        self.badge = badge
        self.footer = footer
        self.imageName = imageName
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if imagePosition == .leading {
                if useImageAsset, let imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                } else if let image {
                        CachedImage(imageRef: image)
                            .frame(width: 120)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
                if imagePosition == .top {
                    if useImageAsset, let imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    } else if let image {
                            CachedImage(imageRef: image)
                            .frame(width: 120)
                    }
                }
                
                if let badge {
                    BadgeView(badge: badge)
                }
                Text(title)
                    .font(Typography.cardTitle)
                    .foregroundStyle(Palette.textPrimary)
                if let bodyText {
                    Text(bodyText)
                        .font(Typography.body)
                        .foregroundStyle(Palette.textSecondary)
                        .lineLimit(3)
                }
                if let footer {
                    DashedLine()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(Palette.textSecondary.opacity(0.3))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)

                    HStack {
                        Text(footer.text)
                            .font(Typography.link)
                            .foregroundStyle(Palette.textAccent)
                        Spacer()
                        if let trailingIcon = footer.trailingIcon {
                            Image(systemName: trailingIcon)
                                .foregroundStyle(Palette.brandPrimary)
                        }
                    }
                    .onTapGesture { actionHandler.handle(footer.action) }
                }
            }
            .padding(Spacing.cardPadding)
        }
        .background(Palette.surfaceDefault)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Palette.surfaceMuted, lineWidth: 2) // Draws the rounded outline
        )
    }
}
