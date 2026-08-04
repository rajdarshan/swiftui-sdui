//
//  Typography.swift
//  SwiftUISDUI
//
//  Text style tokens. design_spec.md §2.2 — fixed sizes, no Dynamic Type.
//  Font (size + weight) only. Line limits, truncation, and eyebrow's
//  uppercase/tracking are applied at each leaf view's call site, not here.
//

import SwiftUI

enum Typography {
    static let display: Font = .system(size: 34, weight: .bold)
    static let sectionTitle: Font = .system(size: 22, weight: .bold)
    static let cardTitle: Font = .system(size: 17, weight: .semibold)
    static let cardSubtitle: Font = .system(size: 15, weight: .regular)
    static let body: Font = .system(size: 15, weight: .regular)
    static let caption: Font = .system(size: 13, weight: .regular)
    static let eyebrow: Font = .system(size: 11, weight: .bold)
    static let price: Font = .system(size: 17, weight: .bold)
    static let priceNote: Font = .system(size: 12, weight: .regular)
    static let link: Font = .system(size: 15, weight: .semibold)
}
