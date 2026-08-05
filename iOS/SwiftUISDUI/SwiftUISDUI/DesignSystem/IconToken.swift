//
//  IconToken.swift
//  SwiftUISDUI
//
//  Icon tokens mapped to SF Symbol names. design_spec.md §2.7. Payloads never
//  contain emoji literals — icons are tokens only.
//
//  `heart`'s selected-state variant (`heart.fill`) is not encoded here; the
//  base/filled swap is applied at the carCard call site via a symbol variant.
//

enum IconToken {
    static let grid = "square.grid.2x2.fill"
    static let car = "car.fill"
    static let key = "key.fill"
    static let money = "indianrupeesign.circle.fill"
    static let receipt = "doc.text.fill"
    static let wrench = "wrench.and.screwdriver.fill"
    static let shield = "checkmark.shield.fill"
    static let phone = "phone.fill"
    static let directions = "arrow.triangle.turn.up.right.diamond.fill"
    static let check = "checkmark.circle"
    static let arrowRightCircle = "arrow.right.circle.fill"
    static let heart = "heart"
    static let chevronDown = "chevron.down"
    static let person = "person.crop.circle.fill"
}
