//
//  ImageCache.swift
//  SwiftUISDUI
//
//  In-memory, session-lifetime image cache. No disk persistence — nothing in
//  the spec asks for it, and reference payloads use placeholder.co demo URLs.
//

import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private var storage: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? {
        storage[url]
    }

    func store(_ image: UIImage, for url: URL) {
        storage[url] = image
    }
}
