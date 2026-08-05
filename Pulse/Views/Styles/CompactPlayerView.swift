//
//  CompactPlayerView.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//


import SwiftUI

struct CompactPlayerView: View {

    @EnvironmentObject var viewModel: MiniPlayerViewModel
    @ObservedObject private var spotify = SpotifyAuthManager.shared
    @EnvironmentObject var appState: AppState
    
    var body: some View {

        HStack(spacing: 16) {
            VStack(alignment: .center, spacing: 16) {
                // MARK: - Title
                MarqueeText(
                    viewModel.song.title,
                    font: .system(size: 24)
                )
                .foregroundStyle(.foreground)
                .shadow(color: viewModel.song.dominantColor.opacity(0.8), radius: 2, x:0, y:0)
                .padding(.bottom,5)
                .frame(maxWidth: .infinity)
                
                // MARK: - Artist
                MarqueeText(
                    viewModel.song.artist,
                    font: .default
                )
                .foregroundStyle(.foreground)
                .shadow(color: viewModel.song.dominantColor.opacity(0.8), radius: 2, x:0, y:0)
                .padding(.bottom,0)
                .frame(maxWidth: .infinity)
                
                // MARK: - Playbar
                PulseSlider(
                    value: $viewModel.sliderProgress,
                    range: 0...viewModel.song.duration,
                    height: 8,
                    progressTint: viewModel.song.dominantColor
                ) { value in
                    Task {
                        try? await SpotifyAPI.shared.seek(to: Int(value))
                        viewModel.song.progress = value
                    }
                }
            }
            .clipped()
        }
        .padding(18)
        .frame(width: 180, height: 110)
        .background {
            PlayerBackground(
                song: viewModel.song,
                artworkURL: viewModel.song.artworkURL
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}
