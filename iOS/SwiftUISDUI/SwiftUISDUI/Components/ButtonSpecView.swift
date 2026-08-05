//
//  ButtonSpecView.swift
//  SwiftUISDUI
//
//  Shared rendering for the ButtonSpec value object (COMPONENTS.md §4.4).
//  `.ghost` renders as a bare text link (section header trailing actions like
//  "View all"); `.filled`/`.outline` get the full button chrome at the
//  design_spec.md §2.5 button height (44). Content-sized, not full-width —
//  width is the call site's decision: placeCard applies
//  .frame(maxWidth: .infinity) per button for its equal-width pair,
//  promoCard/orbit/crashfree leave it compact, matching the reference
//  screenshots.
//
//  Tap dispatches `spec.action` through the environment-injected
//  ActionHandler (design_spec.md §3.2 rule 4) — inert by default, matching
//  the static screen.
//

import SwiftUI

struct ButtonSpecView: View {
    let spec: ButtonSpec

    @Environment(\.actionHandler) private var actionHandler

    var body: some View {
        Group {
            if spec.variant == .ghost {
                label
            } else {
                label
                    .padding(.horizontal, Spacing.cardPadding)
                    .frame(height: 44)
                    .background(background, in: RoundedRectangle(cornerRadius: Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .strokeBorder(spec.variant == .outline ? Palette.brandPrimary : .clear)
                    )
            }
        }
        .onTapGesture { actionHandler.handle(spec.action) }
    }

    private var label: some View {
        HStack(spacing: 8) {
            if let icon = spec.leadingIcon {
                Image(systemName: icon)
            }
            Text(spec.text)
                .font(Typography.link)
        }
        .foregroundStyle(foreground)
    }

    private var background: Color {
        spec.variant == .filled ? Palette.brandPrimary : .clear
    }

    private var foreground: Color {
        switch spec.variant {
        case .filled: Palette.textOnDark
        case .outline, .ghost: Palette.textAccent
        }
    }
}
