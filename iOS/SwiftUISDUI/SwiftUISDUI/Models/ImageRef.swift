//
//  ImageRef.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.2. Holds a resolved Color, not a token
//  string — Stage 2 has no decoder; string→token resolution is Stage 3.
//

import SwiftUI

nonisolated struct ImageRef {
    let url: String
    let placeholder: Color
    let aspect: Double?

    init(url: String, placeholder: Color = Palette.surfaceMuted, aspect: Double? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.aspect = aspect
    }
}

nonisolated extension ImageRef: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case url, placeholder, aspect }

    // COMPONENTS.md §4.2: placeholder default is surface.muted, applied
    // whether the key is absent or the token is unrecognized.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let url = try container.decode(String.self, forKey: .url)
        let placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
            .flatMap(Palette.resolve) ?? Palette.surfaceMuted
        let aspect = try container.decodeIfPresent(Double.self, forKey: .aspect)
        self.init(url: url, placeholder: placeholder, aspect: aspect)
    }
}
