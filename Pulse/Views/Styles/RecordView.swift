//
//  LyricsPlayerView.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//


import SwiftUI
import Combine

struct RecordView: View {
    
    @ObservedObject private var viewModel = MiniPlayerViewModel.shared
    @State private var angle = 0.0
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack{
            ZStack{
                // MARK: - Record ridges
                Capsule()
                    .fill(.clear)
                    .glassEffect(.regular.interactive())
                    .frame(width:500, height:500)
                    .overlay {
                        Capsule()
                            .stroke(appState.backgroundStyle == .darkClear ? .black.opacity(0.6): appState.backgroundStyle == .clear ? .white.opacity(0.2) : appState.backgroundStyle == .artworkTint ? viewModel.song.dominantColor.change.opacity(0.5) : viewModel.song.dominantColor.opacity(0.7), lineWidth: 1)
                            .padding(0.5)
                    }
                Capsule()
                    .fill(.clear)
                    .frame(width:450, height:450)
                    .overlay {
                        Capsule()
                            .stroke(appState.backgroundStyle == .darkClear ? .black.opacity(0.6): appState.backgroundStyle == .clear ? .white.opacity(0.2) : appState.backgroundStyle == .artworkTint ? viewModel.song.dominantColor.change.opacity(0.5) : viewModel.song.dominantColor.opacity(0.7), lineWidth: 1)
                            .padding(0.5)
                    }
                Capsule()
                    .fill(.clear)
                    .frame(width:400, height:400)
                    .overlay {
                        Capsule()
                            .stroke(appState.backgroundStyle == .darkClear ? .black.opacity(0.6): appState.backgroundStyle == .clear ? .white.opacity(0.2) : appState.backgroundStyle == .artworkTint ? viewModel.song.dominantColor.change.opacity(0.5) : viewModel.song.dominantColor.opacity(0.7), lineWidth: 1)
                            .padding(0.5)
                    }
                Capsule()
                    .fill(.clear)
                    .frame(width:350, height:350)
                    .overlay {
                        Capsule()
                            .stroke(appState.backgroundStyle == .darkClear ? .black.opacity(0.6): appState.backgroundStyle == .clear ? .white.opacity(0.2) : appState.backgroundStyle == .artworkTint ? viewModel.song.dominantColor.change.opacity(0.5) : viewModel.song.dominantColor.opacity(0.7), lineWidth: 1)
                            .padding(0.5)
                    }
                Capsule()
                    .fill(.clear)
                    .frame(width:300, height:300)
                    .overlay {
                        Capsule()
                            .stroke(appState.backgroundStyle == .darkClear ? .black.opacity(0.6): appState.backgroundStyle == .clear ? .white.opacity(0.2) : appState.backgroundStyle == .artworkTint ? viewModel.song.dominantColor.change.opacity(0.5) : viewModel.song.dominantColor.opacity(0.7), lineWidth: 1)
                            .padding(0.5)
                    }
                Capsule()
                    .fill(.clear)
                    .frame(width:250, height:250)
                    .overlay {
                        Capsule()
                            .stroke(appState.backgroundStyle == .darkClear ? .black.opacity(0.6): appState.backgroundStyle == .clear ? .white.opacity(0.2) : appState.backgroundStyle == .artworkTint ? viewModel.song.dominantColor.change.opacity(0.5) : viewModel.song.dominantColor.opacity(0.7), lineWidth: 1)
                            .padding(0.5)
                    }
                Capsule()
                    .fill(.clear)
                    .frame(width:200, height:200)
                    .overlay {
                        Capsule()
                            .stroke(appState.backgroundStyle == .darkClear ? .black.opacity(0.6): appState.backgroundStyle == .clear ? .white.opacity(0.2) : appState.backgroundStyle == .artworkTint ? viewModel.song.dominantColor.change.opacity(0.5) : viewModel.song.dominantColor.opacity(0.7), lineWidth: 1)
                            .padding(0.5)
                    }
                
                // MARK: - Center album cover image
                AsyncImage(url: viewModel.song.artworkURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.gray.opacity(0.3))
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .shadow(radius: 12)
            }
            .padding(18)
            .frame(width: 500, height: 500)
            .background {
                PlayerBackground(
                    song: viewModel.song,
                    artworkURL: viewModel.song.artworkURL
                )
            }
            .mask {
                // MARK: - The cutout for the semi transparent layer
                ZStack {
                    Circle()
                    Circle()
                        .frame(width: 25, height: 25) // Change this to adjust hole size
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
            }
            // MARK: - The semi transparent layer
            Circle()
                .fill(viewModel.song.dominantColor.opacity(0.5))
                .frame(width: 25, height: 25)
        }
        .frame(width: 500, height: 500)
        .mask {
            // MARK: - The fully transparent hole
            ZStack {
                Circle()
                Circle()
                    .frame(width: 15, height: 15) // Change this to adjust hole size
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
        }
        .onReceive(timer) { _ in
            guard viewModel.song.isPlaying else { return }
            angle += 0.33 // Adjust for desired RPM
            if angle >= 360 {
                angle -= 360
            }
        }
        .rotationEffect(.degrees(angle))  // Rotates the record
        .onTapGesture {
            Task {
                try? await SpotifyAPI.shared.playPause(isPlaying: viewModel.song.isPlaying) // Play/Pause the song when tapped
                await viewModel.sync()
            }
        }
    }
}

// MARK: - Darken color extension used for visibility
extension Color {
    var change: Color {
        // Convert SwiftUI Color to NSColor
        let nsColor = NSColor(self)
        
        // Force conversion to RGB color space to read components safely on macOS
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return self // Fallback to original color if conversion fails
        }
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        // Extract the original components
        rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // Return inverted SwiftUI Color
        return Color(
            red: max(0.0,(Double(r) * 0.7)),
            green: max(0.0,(Double(g) * 0.7)),
            blue: max(0.0, (Double(b) * 0.7)),
            opacity: Double(a)
        )
    }
}
