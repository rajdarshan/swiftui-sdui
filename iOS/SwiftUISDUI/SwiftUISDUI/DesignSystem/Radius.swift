//
//  Radius.swift
//  SwiftUISDUI
//
//  Corner radius tokens. design_spec.md §2.4.
//

import CoreGraphics

enum Radius {
    static let none: CGFloat = 0
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let pill: CGFloat = 999
}

extension Radius {
    private static let tokens: [String: CGFloat] = [
        "none": Radius.none,
        "sm": sm,
        "md": md,
        "lg": lg,
        "pill": pill
    ]

    /// COMPONENTS.md §10: unknown token → nil. The caller substitutes the
    /// client default; this only resolves recognized names.
    static func resolve(_ token: String) -> CGFloat? {
        tokens[token]
    }
}
