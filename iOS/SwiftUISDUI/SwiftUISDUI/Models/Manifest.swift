//
//  Manifest.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §13: manifest shape — `manifestVersion`, `schemaVersion`
//  (highest in use across payloads, informational only per design_spec.md
//  §3.2 rule 7), `releaseVersion`, `payloads[]` naming each page's bundled
//  path. `entry(forPageId:)` is how BundlePayloadSource resolves a `pageId`
//  to a file, and is also the "known pageId" set ActionDispatch uses to
//  distinguish a header tab's real page-load navigate from every other
//  navigate that resolves to DebugActionScreen.
//

nonisolated struct Manifest: Decodable {
    let manifestVersion: Int
    let schemaVersion: String
    let releaseVersion: String
    let payloads: [ManifestEntry]

    func entry(forPageId pageId: String) -> ManifestEntry? {
        payloads.first { $0.pageId == pageId }
    }
}

nonisolated struct ManifestEntry: Decodable {
    let pageId: String
    let path: String
    let version: String
    let schemaVersion: String
    let minAppVersion: String
}
