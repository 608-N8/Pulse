//
//  ControlsPlayerView.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import SwiftUI
import Foundation
import Combine

struct ControlsPlayerView: View {

    @EnvironmentObject var viewModel: MiniPlayerViewModel
    @ObservedObject private var spotify = SpotifyAuthManager.shared
    @EnvironmentObject var appState: AppState
    
    var body: some View {

        HStack() {
            // MARK: - Album cover
            AsyncImage(url: viewModel.song.artworkURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.gray.opacity(0.3))
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(radius: 12)

            VStack(alignment: .center) {

                // MARK: - Title
                MarqueeText(
                    viewModel.song.title,
                    font: .headline,
                )
                .foregroundStyle(.foreground)
                .shadow(color: viewModel.song.dominantColor.opacity(0.8), radius: 2, x:0, y:0)
                .padding(.bottom,0)
                .frame(maxWidth: .infinity)
                
                // MARK: - Artist
                MarqueeText(
                    viewModel.song.artist,
                    font: .subheadline
                )
                .foregroundStyle(.foreground)
                .shadow(color: viewModel.song.dominantColor.opacity(0.8), radius: 2, x:0, y:0)
                .padding(.bottom,0)
                .frame(maxWidth: .infinity)
                
                // MARK: Playbar
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
            
            HStack(spacing: 12) {
                // MARK: - Previous track button
                Button {
                    Task {
                        try? await SpotifyAPI.shared.previousTrack()
                        await viewModel.sync()
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .contentShape(Circle())
                }
                .buttonStyle(PulseGlassButtonStyle(tint: viewModel.song.dominantColor, width: 40, height: 40))
                
                // MARK: - Play/Pause button
                Button {
                    Task {
                        try? await SpotifyAPI.shared.playPause(
                            isPlaying: viewModel.song.isPlaying
                        )
                        await viewModel.sync()
                    }
                } label: {
                    Image(
                        systemName: viewModel.song.isPlaying
                        ? "pause.fill"
                        : "play.fill"
                    )
                    .contentShape(Circle())
                }
                .buttonStyle(PulseGlassButtonStyle(tint: viewModel.song.dominantColor, width: 40, height: 40))
                
                // MARK: - Next track button
                Button {
                    Task {
                        try? await SpotifyAPI.shared.nextTrack()
                        await viewModel.sync()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .contentShape(Circle())
                }
                .buttonStyle(PulseGlassButtonStyle(tint: viewModel.song.dominantColor, width: 40, height: 40))
            }
        }
        .padding(18)
        .frame(width: 360, height: 110)
        .background {
            PlayerBackground(
                song: viewModel.song,
                artworkURL: viewModel.song.artworkURL
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}
