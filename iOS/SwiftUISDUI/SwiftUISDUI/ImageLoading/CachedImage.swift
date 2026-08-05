//
//  CachedImage.swift
//  SwiftUISDUI
//
//  Custom cached async image loader. AsyncImage is prohibited — no cache,
//  refetches on redraw. design_spec.md §4.1.
//
//  Three phases: `loading` shows the placeholder at the declared aspect so
//  layout doesn't shift when the image arrives; `failed` collapses the slot
//  to zero size so text-only content still renders (COMPONENTS.md §10).
//
//  placehold.co (used by every reference/demo URL, including the actual
//  home_all.json payload) serves SVG by default, which UIImage cannot
//  decode — every image silently failed until this was found via a real
//  simulator screenshot. Normalized to its .png variant here, at the
//  loader, rather than editing every URL string at the data layer.
//

import SwiftUI

struct CachedImage: View {
    let imageRef: ImageRef

    @State private var phase: Phase = .loading

    private enum Phase {
        case loading
        case loaded(UIImage)
        case failed
    }

    var body: some View {
        Group {
            switch phase {
            case .loading:
                Rectangle()
                    .fill(imageRef.placeholder)
                    .aspectRatio(imageRef.aspect.map { CGFloat($0) }, contentMode: .fill)
            case .loaded(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .aspectRatio(imageRef.aspect.map { CGFloat($0) }, contentMode: .fill)
            case .failed:
                Color.clear.frame(width: 0, height: 0)
            }
        }
        .clipped()
        .task(id: imageRef.url) {
            await load()
        }
    }

    private func load() async {
        guard let rawURL = URL(string: imageRef.url) else {
            phase = .failed
            return
        }
        let url = normalizedPlaceholderURL(rawURL)
        if let cached = await ImageCache.shared.image(for: url) {
            phase = .loaded(cached)
            return
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let uiImage = UIImage(data: data) else {
            phase = .failed
            return
        }
        await ImageCache.shared.store(uiImage, for: url)
        phase = .loaded(uiImage)
    }

    /// placehold.co serves SVG unless its *last* path segment carries an
    /// explicit extension (e.g. "600x400/F1F3F9/333333.png" — not on the
    /// dimensions segment, confirmed against the live service). Inserts
    /// ".png" there so UIImage can decode the response; leaves every other
    /// host untouched.
    private func normalizedPlaceholderURL(_ url: URL) -> URL {
        guard url.host == "placehold.co" else { return url }
        let segments = url.pathComponents.filter { $0 != "/" }
        guard let last = segments.last, !last.contains(".") else { return url }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        let leading = segments.dropLast().joined(separator: "/")
        components.path = leading.isEmpty ? "/\(last).png" : "/\(leading)/\(last).png"
        return components.url ?? url
    }
}
