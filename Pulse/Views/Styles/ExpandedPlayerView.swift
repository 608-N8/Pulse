//
//  ExpandedPlayerView.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//


import SwiftUI

struct ExpandedPlayerView: View {

    @ObservedObject private var viewModel = MiniPlayerViewModel.shared
    @ObservedObject private var spotify = SpotifyAuthManager.shared
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        VStack(alignment:.center){
            // MARK: - Album cover
            AsyncImage(url: viewModel.song.artworkURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.gray.opacity(0.3))
            }
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(radius: 12)
            
            VStack(alignment:.center){
                // MARK: - Title
                MarqueeText(
                    viewModel.song.title,
                    font: .system(size: 24)
                )
                    .bold()
                    .foregroundStyle(.foreground)
                    .shadow(color: viewModel.song.dominantColor.opacity(0.8), radius: 2, x:0, y:0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // MARK: - Artist
                MarqueeText(
                    viewModel.song.artist,
                    font: .default
                )
                    .foregroundStyle(.foreground)
                    .shadow(color: viewModel.song.dominantColor.opacity(0.8), radius: 2, x:0, y:0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity)
            .clipped()
            
            
            HStack(alignment:.center, spacing: 12) {
                
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
                .buttonStyle(PulseGlassButtonStyle(tint: viewModel.song.dominantColor, width: 50, height: 50))
                
                // MARK: - Play/Pause button
                Button {
                    Task {
                        try? await SpotifyAPI.shared.playPause(isPlaying: viewModel.song.isPlaying)
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
                .buttonStyle(PulseGlassButtonStyle(tint: viewModel.song.dominantColor, width: 50, height: 50))
                
                // MARK: Next track button
                Button {
                    Task {
                        try? await SpotifyAPI.shared.nextTrack()
                        await viewModel.sync()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .contentShape(Circle())
                }
                .buttonStyle(PulseGlassButtonStyle(tint: viewModel.song.dominantColor, width: 50, height: 50))
            }
            
            HStack(alignment:.center){
                // MARK: Current song progress
                Text(formatMilliseconds(Int(viewModel.sliderProgress)))
                    .foregroundStyle(.foreground)
                    .shadow(color: viewModel.song.dominantColor.opacity(0.8), radius: 2, x:0, y:0)
                
                // MARK: Playbar
                PulseSlider(
                    value: $viewModel.sliderProgress,
                    range: 0...viewModel.song.duration,

                    height: 7,

                    progressTint: viewModel.song.dominantColor
                ) { value in

                    Task {

                        try? await SpotifyAPI.shared.seek(to: Int(value))
                        viewModel.song.progress = value

                    }

                }
                
                // MARK: Current song length
                Text(formatMilliseconds(Int(ceil(viewModel.song.duration))))
                    .foregroundStyle(.foreground)
                    .shadow(color: viewModel.song.dominantColor.opacity(0.8), radius: 2, x:0, y:0)
            }
        }
        .padding(18)
        .frame(width: 400, height: 480)
        .background {
            PlayerBackground(
                song: viewModel.song,
                artworkURL: viewModel.song.artworkURL
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    // Converts milliseconds to Minute:Second format
    func formatMilliseconds(_ milliseconds: Int) -> String {
        let totalSeconds = milliseconds / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        print(viewModel.sliderProgress)
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
