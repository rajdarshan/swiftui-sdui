//
//  PlaceCardView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: images M [ImageRef] (min 1), title M, overlayBadge O,
//  subtitle O, linkRow O {text, trailingIcon?, action}, status O {text,
//  detail?, variant}, buttons O [Button] (0-2).
//  design_spec.md §4.3/§4.4: image pager uses TabView(.page) — the one
//  sanctioned use outside the value-prop carousel, since there's no loop
//  here. A single-image placeCard skips the pager machinery entirely.
//  Notched overlay badge bottom-leading. Two buttons in an HStack, equal
//  width.
//
//  `linkRow` dispatches its `action` through the environment-injected
//  ActionHandler (design_spec.md §3.2 rule 4) — inert by default, matching
//  the static screen. `buttons` already route through ButtonSpecView, which
//  handles its own dispatch.
//

import SwiftUI

struct PlaceCardLinkRow {
    let text: String
    let trailingIcon: String?
    let action: Action

    init(text: String, trailingIcon: String? = nil, action: Action) {
        self.text = text
        self.trailingIcon = trailingIcon
        self.action = action
    }
}

struct PlaceCardStatus {
    let text: String
    let detail: String?
    let variant: Badge.Variant

    init(text: String, detail: String? = nil, variant: Badge.Variant = .neutral) {
        self.text = text
        self.detail = detail
        self.variant = variant
    }
}

struct PlaceCardView: View {
    let images: [ImageRef]
    let title: String
    let overlayBadge: Badge?
    let subtitle: String?
    let linkRow: PlaceCardLinkRow?
    let status: PlaceCardStatus?
    let buttons: [ButtonSpec]

    @Environment(\.actionHandler) private var actionHandler

    init(
        images: [ImageRef],
        title: String,
        overlayBadge: Badge? = nil,
        subtitle: String? = nil,
        linkRow: PlaceCardLinkRow? = nil,
        status: PlaceCardStatus? = nil,
        buttons: [ButtonSpec] = []
    ) {
        self.images = images
        self.title = title
        self.overlayBadge = overlayBadge
        self.subtitle = subtitle
        self.linkRow = linkRow
        self.status = status
        self.buttons = buttons
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

            if let linkRow {
                HStack(spacing: 4) {
                    Text(linkRow.text)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textAccent)
                    if let icon = linkRow.trailingIcon {
                        Image(systemName: icon)
                            .foregroundStyle(Palette.textAccent)
                    }
                }
                .onTapGesture { actionHandler.handle(linkRow.action) }
            }

            if let status {
                HStack(spacing: 4) {
                    Text(status.text)
                        .font(Typography.caption)
                        .foregroundStyle(statusColor(status.variant))
                    if let detail = status.detail {
                        Text(detail)
                            .font(Typography.caption)
                            .foregroundStyle(Palette.textSecondary)
                    }
                }
            }

            if !buttons.isEmpty {
                HStack(spacing: Spacing.cardPadding) {
                    ForEach(buttons, id: \.text) { spec in
                        ButtonSpecView(spec: spec)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(Spacing.cardPadding)
        .background(Palette.surfaceDefault)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    @ViewBuilder private var imageArea: some View {
        ZStack(alignment: .bottomLeading) {
            if images.count > 1 {
                TabView {
                    ForEach(images, id: \.url) { imageRef in
                        CachedImage(imageRef: imageRef)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 180)
            } else if let first = images.first {
                CachedImage(imageRef: first)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            }

            if let overlayBadge {
                BadgeView(badge: overlayBadge)
                    .padding(Spacing.cardPadding)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private func statusColor(_ variant: Badge.Variant) -> Color {
        switch variant {
        case .success: Palette.textSuccess
        case .danger: Palette.textDanger
        default: Palette.textPrimary
        }
    }
}
