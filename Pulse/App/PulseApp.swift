//
//  PulseApp.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import SwiftUI

@main
struct PulseApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var viewModel = MiniPlayerViewModel.shared

    var body: some Scene {
        WindowGroup {
            MiniPlayerView()
                .environmentObject(appState)
                .environmentObject(viewModel)
                .onAppear {
                    appState.windowManager.setupMainWindow()
                    SpotifyAuthManager.shared.restoreSession() // Restores auth if already authorized
                    viewModel.start()
                }
        }
        .commands {
            AppearanceCommands()
        }
    }
}
