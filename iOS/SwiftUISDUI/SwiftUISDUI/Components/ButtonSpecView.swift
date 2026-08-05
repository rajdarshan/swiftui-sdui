//
//  ButtonSpecView.swift
//  SwiftUISDUI
//
//  Shared rendering for the ButtonSpec value object (COMPONENTS.md §4.4).
//  `.ghost` renders as a bare text link (section header trailing actions like
//  "View all"); `.filled`/`.outline` get the full button chrome at the
//  design_spec.md §2.5 button height (44).
//

import SwiftUI

struct ButtonSpecView: View {
    let spec: ButtonSpec

    var body: some View {
        Group {
            if spec.variant == .ghost {
                label
            } else {
                label
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(background, in: RoundedRectangle(cornerRadius: Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .strokeBorder(spec.variant == .outline ? Palette.brandPrimary : .clear)
                    )
            }
        }
        .onTapGesture {}
    }

    private var label: some View {
        HStack(spacing: 6) {
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
