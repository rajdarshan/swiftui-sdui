//
//  BadgeView.swift
//  SwiftUISDUI
//
//  Shared rendering for the Badge value object (COMPONENTS.md §4.3), used by
//  section headers, carCard's overlayBadge/trustBadges, placeCard's
//  overlayBadge, etc. Variant → exact colour is a client decision
//  (COMPONENTS.md's division-of-responsibility table).
//

import SwiftUI

struct BadgeView: View {
    let badge: Badge

    var body: some View {
        HStack(spacing: 4) {
            if let icon = badge.icon {
                Image(systemName: icon)
                    .font(.system(size: 11))
            }
            Text(badge.text)
                .font(Typography.caption)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(background, in: Capsule())
    }

    private var background: Color {
        switch badge.variant {
        case .neutral: Palette.surfaceChip
        case .accent: Palette.brandPrimary.opacity(0.12)
        case .success: Palette.textSuccess.opacity(0.12)
        case .warning: Palette.tileOrange.opacity(0.12)
        case .danger: Palette.badgeDanger
        }
    }

    private var foreground: Color {
        switch badge.variant {
        case .neutral: Palette.textPrimary
        case .accent: Palette.textAccent
        case .success: Palette.textSuccess
        case .warning: Palette.tileOrange
        case .danger: Palette.textOnDark
        }
    }
}
