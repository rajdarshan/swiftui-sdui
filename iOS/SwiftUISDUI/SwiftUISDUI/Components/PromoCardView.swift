//
//  PromoCardView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, image O, eyebrow O, subtitle O, logos O
//  [ImageRef], button O, style O.
//  design_spec.md §4.4: ZStack, image trailing-aligned, may bleed to the
//  card edge. Text leading. Optional logo row above the title.
//  design_spec.md §2.2: eyebrow is uppercase, +0.5 tracking.
//

import SwiftUI

struct PromoCardView: View {
    let title: String
    let image: ImageRef?
    let eyebrow: String?
    let subtitle: String?
    let logos: [ImageRef]
    let button: ButtonSpec?
    let style: Style?

    init(
        title: String,
        image: ImageRef? = nil,
        eyebrow: String? = nil,
        subtitle: String? = nil,
        logos: [ImageRef] = [],
        button: ButtonSpec? = nil,
        style: Style? = nil
    ) {
        self.title = title
        self.image = image
        self.eyebrow = eyebrow
        self.subtitle = subtitle
        self.logos = logos
        self.button = button
        self.style = style
    }

    private var foreground: Color { style?.foreground ?? Palette.textOnDark }

    var body: some View {
        ZStack(alignment: .topLeading) {
            style?.background ?? Palette.brandPrimary

            if let image {
                CachedImage(imageRef: image)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }

            VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
                if !logos.isEmpty {
                    HStack(spacing: Spacing.sectionHeaderToContent) {
                        ForEach(logos, id: \.url) { logo in
                            CachedImage(imageRef: logo)
                                .frame(height: 24)
                        }
                    }
                }
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(Typography.eyebrow)
                        .tracking(0.5)
                        .foregroundStyle(foreground)
                }
                Text(title)
                    .font(Typography.sectionTitle)
                    .foregroundStyle(foreground)
                if let subtitle {
                    Text(subtitle)
                        .font(Typography.body)
                        .foregroundStyle(foreground.opacity(0.85))
                }
                if let button {
                    ButtonSpecView(spec: button)
                }
            }
            .padding(Spacing.cardPadding)
        }
        .clipShape(RoundedRectangle(cornerRadius: style?.cornerRadius ?? Radius.lg))
    }
}
