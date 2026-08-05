//
//  ImageRef.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.2. Holds a resolved Color, not a token
//  string — Stage 2 has no decoder; string→token resolution is Stage 3.
//

import SwiftUI

struct ImageRef {
    let url: String
    let placeholder: Color
    let aspect: Double?

    init(url: String, placeholder: Color = Palette.surfaceMuted, aspect: Double? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.aspect = aspect
    }
}
