//
//  ArtworkManager.swift
//  Pulse
//
//  Created by Nate Patton on 8/4/26.
//

import SwiftUI
import AppKit

actor ArtworkManager {

    static let shared = ArtworkManager()

    struct Artwork {
        let image: NSImage
        let dominantColor: Color
    }

    private var cache: [URL: Artwork] = [:]

    func artwork(for url: URL) async throws -> Artwork {
        if let cached = cache[url] {
            return cached
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = NSImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        let color = Self.extractDominantColor(from: image)

        let artwork = Artwork(image: image, dominantColor: Color(nsColor: color))  // sets Artwork to be the album cover and the dominant color

        cache[url] = artwork
        return artwork
    }

    private static func extractDominantColor(from image: NSImage) -> NSColor { // Gets the dominant color from an image

        guard
            let tiff = image.tiffRepresentation,
            let rep = NSBitmapImageRep(data: tiff)
        else {

            return .systemGray

        }

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var total: CGFloat = 0

        let width = min(32, rep.pixelsWide)
        let height = min(32, rep.pixelsHigh)

        for x in 0..<width {
            for y in 0..<height {
                guard
                    let color = rep.colorAt(x: x, y: y)?
                        .usingColorSpace(.deviceRGB)
                else {
                    continue
                }

                r += color.redComponent
                g += color.greenComponent
                b += color.blueComponent

                total += 1
            }
        }

        guard total > 0 else {
            return .systemGray
        }

        return NSColor(
            red: r / total,
            green: g / total,
            blue: b / total,
            alpha: 1
        )
    }
}
