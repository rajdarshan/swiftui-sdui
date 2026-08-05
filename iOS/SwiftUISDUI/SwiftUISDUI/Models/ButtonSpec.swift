//
//  ButtonSpec.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.4, calls it "Button" — renamed here to
//  avoid colliding with SwiftUI.Button.
//

struct ButtonSpec {
    enum Variant {
        case filled, outline, ghost
    }

    let text: String
    let action: Action
    let variant: Variant
    let leadingIcon: String?

    init(text: String, action: Action, variant: Variant = .filled, leadingIcon: String? = nil) {
        self.text = text
        self.action = action
        self.variant = variant
        self.leadingIcon = leadingIcon
    }
}
