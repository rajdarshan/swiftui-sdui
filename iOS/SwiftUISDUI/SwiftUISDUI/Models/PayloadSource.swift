//
//  PayloadSource.swift
//  SwiftUISDUI
//
//  design_spec.md §3.1: PayloadSource (protocol, async). BundlePayloadSource
//  implements this for stages 1-5; SupabasePayloadSource (stage 6) will be a
//  second conformer, not built here.
//

nonisolated protocol PayloadSource {
    func loadManifest() async throws -> Manifest
    func loadPage(pageId: String) async throws -> PageEnvelope
}

nonisolated enum PayloadSourceError: Error, Equatable {
    case unknownPageId(String)
    case resourceNotFound(String)
}
