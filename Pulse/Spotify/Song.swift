//
//  Song.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import Foundation
import SwiftUI

struct Song {

    let title: String
    let artist: String
    let artworkURL: URL?
    var progress: Double
    let duration: Double
    let isPlaying: Bool
    var dominantColor: Color = .clear

    static let placeholder = Song(
        title: "Not Playing",
        artist: "Spotify",
        artworkURL: nil,
        progress: 0,
        duration: 1,
        isPlaying: false
    )

}
