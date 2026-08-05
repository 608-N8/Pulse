//
//  AppState.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {

    let windowManager = WindowManager()
    let spotify = SpotifyAuthManager.shared
    
    @Published var playerMode: PlayerMode = .controls // Default player mode
    @Published var backgroundStyle: BackgroundStyle = .adaptive // Default background style
    
    static let shared = AppState()
    private var cancellables = Set<AnyCancellable>()

    private init() {
        $playerMode
            .sink { [weak self] mode in
                self?.windowManager.setMode(mode)
            }
            .store(in: &cancellables)
    }
}
