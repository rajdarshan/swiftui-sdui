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
