//
//  SpotifyAPI.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import Foundation
import SwiftUI
import AppKit

@MainActor
final class SpotifyAPI {

    static let shared = SpotifyAPI()

    // MARK: - Asks Spotify for the current track
    func currentTrack() async throws -> Song {
        guard let token = SpotifyAuthManager.shared.accessToken else {
            throw URLError(.userAuthenticationRequired)
        }

        var request = URLRequest(
            url: URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!
        )
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Nothing currently playing
        if http.statusCode == 204 {
            return .placeholder
        }

        // Spotify rate limit
        if http.statusCode == 429 {
            if let retry = http.value(forHTTPHeaderField: "Retry-After"),
               let seconds = Double(retry) {

                print("Spotify rate limited. Waiting \(seconds)s")
                try? await Task.sleep(for: .seconds(seconds))
            }
            
            return .placeholder
        }

        guard http.statusCode == 200 else {
            print(http.statusCode)
            print(String(decoding: data, as: UTF8.self))
            throw URLError(.badServerResponse)
        }

        let playback = try JSONDecoder().decode(
            SpotifyPlayback.self,
            from: data
        )

        guard let item = playback.item else {
            return .placeholder
        }

        var song = Song(
            title: item.name,
            artist: item.artists.map(\.name).joined(separator: ", "),
            artworkURL: URL(string: item.album.images.first?.url ?? ""),
            progress: playback.progressMS,
            duration: item.durationMS,
            isPlaying: playback.isPlaying
        )

        if let artworkURL = song.artworkURL {
            do {
                let artwork = try await ArtworkManager.shared.artwork(
                    for: artworkURL
                )
                song.dominantColor = artwork.dominantColor
            } catch {
                print("Artwork error:", error)
            }
        }
        
        return song
    }

    // MARK: - Tells Spotify to play/pause the current song
    func playPause(isPlaying: Bool) async throws {
        guard let token = SpotifyAuthManager.shared.accessToken else {
            return
        }

        let endpoint = isPlaying ? "pause" : "play"
        var request = URLRequest(
            url: URL(string: "https://api.spotify.com/v1/me/player/\(endpoint)")!
        )

        request.httpMethod = "PUT"
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        _ = try await URLSession.shared.data(for: request)
    }
    
    // MARK: - Tells Spotify to go to the next track
    func nextTrack() async throws {
        guard let token = SpotifyAuthManager.shared.accessToken else {
            return
        }

        var request = URLRequest(
            url: URL(string: "https://api.spotify.com/v1/me/player/next")!
        )
        request.httpMethod = "POST"
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        _ = try await URLSession.shared.data(for: request)
    }
    
    // MARK: - Tells Spotify to go to the previous track
    func previousTrack() async throws {
        guard let token = SpotifyAuthManager.shared.accessToken else {
            return
        }

        var request = URLRequest(
            url: URL(string: "https://api.spotify.com/v1/me/player/previous")!
        )

        request.httpMethod = "POST"

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        _ = try await URLSession.shared.data(for: request)

    }
    
    // MARK: - Tells Spotify to seek the song to the given millisecond
    func seek(to milliseconds: Int) async throws {

        guard let token = SpotifyAuthManager.shared.accessToken else {
            return
        }

        var components = URLComponents(
            string: "https://api.spotify.com/v1/me/player/seek"
        )!
        components.queryItems = [
            URLQueryItem(
                name: "position_ms",
                value: "\(milliseconds)"
            )
        ]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "PUT"
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        
        _ = try await URLSession.shared.data(for: request)
    }
}
