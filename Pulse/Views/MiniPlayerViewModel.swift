import SwiftUI
import Combine
import AppKit

@MainActor
final class MiniPlayerViewModel: ObservableObject {

    static let shared = MiniPlayerViewModel()
    @Published var menusAreOpen = false
    @Published var song = Song.placeholder
    @Published var sliderProgress: Double = 0
    @Published var isDraggingSlider = false
    private var syncTask: Task<Void, Never>?
    private var progressTask: Task<Void, Never>?

    private init() {
        
        // Checks to see if the command menu is open
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(menuDidOpen),
            name: NSMenu.didBeginTrackingNotification,
            object: nil
        )
        
        // Checks to see if the command menu is closed
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(menuDidClose),
            name: NSMenu.didEndTrackingNotification,
            object: nil
        )
    }

    @objc
    private func menuDidOpen() {
        menusAreOpen = true
    }

    @objc
    private func menuDidClose() {
        menusAreOpen = false
    }

    func start() {
        guard syncTask == nil else { return }
        Task {
            await sync()
        }
        
        syncTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5)) // Waits 5 seconds before syncing the Spotify data to the app

                guard !menusAreOpen else { continue }

                await sync()
            }
        }

        progressTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1)) // Wait 1 second before updating the playbar
                
                guard !menusAreOpen else { continue }
                guard song.isPlaying else { continue }
                guard !isDraggingSlider else { continue }

                song.progress = min(song.progress + 1000, song.duration)
                sliderProgress = song.progress
            }

        }

    }
    
    // Syncs the song to the current track
    func sync() async {
        do {
            let newSong = try await SpotifyAPI.shared.currentTrack()
            song = newSong
            if !isDraggingSlider {
                sliderProgress = newSong.progress
            }
        } catch {
            print(error)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        syncTask?.cancel()
        progressTask?.cancel()
    }
}
