//
//  Badge.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.3. `icon` is an already-resolved SF Symbol
//  name (via IconToken), not a token string.
//

struct Badge {
    enum Variant: String {
        case neutral, accent, success, warning, danger
    }

    let text: String
    let icon: String?
    let variant: Variant

    init(text: String, icon: String? = nil, variant: Variant = .neutral) {
        self.text = text
        self.icon = icon
        self.variant = variant
    }
}
