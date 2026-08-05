//
//  Style.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.5. Holds resolved Color/CGFloat, not
//  token strings — Stage 2 has no decoder; string→token resolution is Stage 3.
//

import SwiftUI

struct Style {
    let background: Color?
    let foreground: Color?
    let border: Color?
    let cornerRadius: CGFloat?

    init(background: Color? = nil, foreground: Color? = nil, border: Color? = nil, cornerRadius: CGFloat? = nil) {
        self.background = background
        self.foreground = foreground
        self.border = border
        self.cornerRadius = cornerRadius
    }
}

extension Style: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case background, foreground, border, cornerRadius }

    // All four fields stay optional on an unknown token — COMPONENTS.md
    // §10's "client default substituted" is already each leaf view's own
    // `style?.x ?? Palette.y` call-site fallback (design_spec.md §4.4).
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            background: try container.decodeIfPresent(String.self, forKey: .background).flatMap(Palette.resolve),
            foreground: try container.decodeIfPresent(String.self, forKey: .foreground).flatMap(Palette.resolve),
            border: try container.decodeIfPresent(String.self, forKey: .border).flatMap(Palette.resolve),
            cornerRadius: try container.decodeIfPresent(String.self, forKey: .cornerRadius).flatMap(Radius.resolve)
        )
    }
}
