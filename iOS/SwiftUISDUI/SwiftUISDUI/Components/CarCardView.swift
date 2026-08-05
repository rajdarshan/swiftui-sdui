//
//  CarCardView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: image M, title M, price M, action M, overlayBadge O,
//  favorite O {selected, action}, subtitle O, specs O [String], priceSuffix
//  O, priceNote O {text, action?}, trustBadges O [Badge].
//  design_spec.md §4.4: VStack. Heart overlay top-trailing; overlay badge
//  centred on the image's bottom edge, straddling the boundary. Spec chips
//  wrap to one line, clipped. Dotted underline on tappable priceNote.
//  trustBadges render as the card's bottom-most row, icon+text pairs with no
//  pill background — confirmed from reference/IMG_4362.PNG (design_spec.md
//  never states their position).
//

import SwiftUI

struct CarCardFavorite {
    let selected: Bool
    let action: Action
}

struct CarCardPriceNote {
    let text: String
    let action: Action?

    init(text: String, action: Action? = nil) {
        self.text = text
        self.action = action
    }
}

struct CarCardView: View {
    let image: ImageRef
    let title: String
    let price: String
    let action: Action
    let overlayBadge: Badge?
    let favorite: CarCardFavorite?
    let subtitle: String?
    let specs: [String]
    let priceSuffix: String?
    let priceNote: CarCardPriceNote?
    let trustBadges: [Badge]

    init(
        image: ImageRef,
        title: String,
        price: String,
        action: Action,
        overlayBadge: Badge? = nil,
        favorite: CarCardFavorite? = nil,
        subtitle: String? = nil,
        specs: [String] = [],
        priceSuffix: String? = nil,
        priceNote: CarCardPriceNote? = nil,
        trustBadges: [Badge] = []
    ) {
        self.image = image
        self.title = title
        self.price = price
        self.action = action
        self.overlayBadge = overlayBadge
        self.favorite = favorite
        self.subtitle = subtitle
        self.specs = specs
        self.priceSuffix = priceSuffix
        self.priceNote = priceNote
        self.trustBadges = trustBadges
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
            imageArea

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

            if !specs.isEmpty {
                HStack(spacing: 6) {
                    ForEach(specs, id: \.self) { spec in
                        Text(spec)
                            .font(Typography.caption)
                            .foregroundStyle(Palette.textPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Palette.surfaceChip, in: Capsule())
                    }
                }
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .clipped()
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(price)
                    .font(Typography.price)
                    .foregroundStyle(Palette.textPrimary)
                if let priceSuffix {
                    Text(priceSuffix)
                        .font(Typography.priceNote)
                        .foregroundStyle(Palette.textSecondary)
                }
            }

            if let priceNote {
                Text(priceNote.text)
                    .font(Typography.priceNote)
                    .foregroundStyle(Palette.textSecondary)
                    .underline(priceNote.action != nil, pattern: .dot)
                    .onTapGesture {}
            }

            if !trustBadges.isEmpty {
                HStack(spacing: Spacing.sectionHeaderToContent) {
                    ForEach(trustBadges, id: \.text) { badge in
                        HStack(spacing: 4) {
                            if let icon = badge.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 12))
                            }
                            Text(badge.text)
                                .font(Typography.caption)
                        }
                        .foregroundStyle(trustBadgeForeground(badge.variant))
                    }
                }
            }
        }
        .padding(Spacing.cardPadding)
        .background(Palette.surfaceDefault)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .onTapGesture {}
    }

    private var imageArea: some View {
        ZStack(alignment: .topTrailing) {
            CachedImage(imageRef: image)
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))

            if let favorite {
                Image(systemName: IconToken.heart)
                    .symbolVariant(favorite.selected ? .fill : .none)
                    .foregroundStyle(favorite.selected ? Palette.brandPrimary : Palette.textSecondary)
                    .padding(8)
                    .background(Palette.surfaceDefault, in: Circle())
                    .padding(Spacing.cardPadding)
                    .onTapGesture {}
            }

            if let overlayBadge {
                BadgeView(badge: overlayBadge)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(y: 12)
            }
        }
    }

    private func trustBadgeForeground(_ variant: Badge.Variant) -> Color {
        switch variant {
        case .neutral: Palette.textSecondary
        case .accent: Palette.textAccent
        case .success: Palette.textSuccess
        case .warning: Palette.tileOrange
        case .danger: Palette.textDanger
        }
    }
}
