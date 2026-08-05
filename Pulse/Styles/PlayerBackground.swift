//
//  PlayerBackground.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//


import SwiftUI

struct PlayerBackground: View {

    @EnvironmentObject var appState: AppState
    
    let song: Song

    let artworkURL: URL?

    var body: some View {
        switch appState.backgroundStyle {

        case .clear:
            RoundedRectangle(cornerRadius: 30)
                .fill(.white.opacity(0.3))

        case .darkClear:
            RoundedRectangle(cornerRadius: 30)
                .fill(.black.opacity(0.6))

        case .artworkTint:
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(song.dominantColor.opacity(0.8))
                }

        case .adaptive:
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.thinMaterial)
                AsyncImage(url: artworkURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.clear
                }
                .blur(radius: 5)
                .scaleEffect(1.6)
                .opacity(0.8)
            }
        }
    }
}
