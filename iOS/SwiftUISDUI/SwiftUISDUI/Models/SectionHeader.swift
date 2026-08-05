//
//  SectionHeader.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.6, calls it "Header" — renamed here to
//  avoid colliding with the app-level header component (COMPONENTS.md §9).
//

nonisolated struct SectionHeader {
    let title: String
    let badge: Badge?
    let trailing: ButtonSpec?

    init(title: String, badge: Badge? = nil, trailing: ButtonSpec? = nil) {
        self.title = title
        self.badge = badge
        self.trailing = trailing
    }
}

// No token resolution or absent-key defaults needed — synthesized
// Decodable already calls decodeIfPresent for the two Optional fields.
nonisolated extension SectionHeader: Decodable, Equatable {}
