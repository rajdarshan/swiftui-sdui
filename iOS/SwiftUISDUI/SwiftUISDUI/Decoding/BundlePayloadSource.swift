//
//  BundlePayloadSource.swift
//  SwiftUISDUI
//
//  design_spec.md §3.1: BundlePayloadSource, stages 1-5. Reads the manifest
//  and payload JSON from the app bundle.
//
//  The payload JSON lives at iOS/SwiftUISDUI/SwiftUISDUI/Resources/Payloads/
//  in the source tree, but Xcode's synchronized-group resource copy drops
//  that directory structure — confirmed by inspecting the built .app, every
//  file lands flat at the bundle root. Resolution therefore looks up each
//  payload by its filename stem (derived from the manifest entry's `path`),
//  not by a nested subdirectory.
//

import Foundation

nonisolated struct BundlePayloadSource: PayloadSource {
    let bundle: Bundle
    let registry: ComponentRegistry

    init(bundle: Bundle = .main, registry: ComponentRegistry = .shared) {
        self.bundle = bundle
        self.registry = registry
    }

    func loadManifest() async throws -> Manifest {
        guard let url = bundle.url(forResource: "config", withExtension: "json") else {
            throw PayloadSourceError.resourceNotFound("config.json")
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Manifest.self, from: data)
    }

    func loadPage(pageId: String) async throws -> PageEnvelope {
        let manifest = try await loadManifest()
        guard let entry = manifest.entry(forPageId: pageId) else {
            throw PayloadSourceError.unknownPageId(pageId)
        }
        let resourceName = (entry.path as NSString).lastPathComponent
            .replacingOccurrences(of: ".json", with: "")
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw PayloadSourceError.resourceNotFound(resourceName)
        }
        let data = try Data(contentsOf: url)
        return try PayloadDecoder.decode(data, registry: registry)
    }
}
