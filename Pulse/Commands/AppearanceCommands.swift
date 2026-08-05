//
//  AppearanceCommands.swift
//  Pulse
//
//  Created by Nate Patton on 8/4/26.
//

import SwiftUI

struct AppearanceCommands: Commands {

    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var spotify = SpotifyAuthManager.shared

    var body: some Commands {

        CommandMenu("Pulse Settings") {
            Picker("Player Style", selection: $appState.playerMode) { // Selector for the player style
                ForEach(PlayerMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized)
                        .tag(mode)
                }
            }

            Divider()

            Picker("Background", selection: $appState.backgroundStyle) { // Selector for the background options
                ForEach(BackgroundStyle.allCases, id: \.self) { style in
                    Text(style.title)
                        .tag(style)
                }
            }
            
            Divider()
            
            Menu("Spotift Link") {  // Menu command for signing in and reset auth
                Button("Spotify Auth Sign In") {
                    spotify.resetAuthentication()
                    spotify.signIn()
                }
                
                Button("Spotify Auth Reset") {
                    spotify.resetAuthentication()
                }
            }
        }
    }
}
