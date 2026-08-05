//
//  MiniPlayerView.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//


import SwiftUI

struct MiniPlayerView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {

        Group {
            switch appState.playerMode {

            case .compact:
                CompactPlayerView()

            case .controls:
                ControlsPlayerView()

            case .expanded:
                ExpandedPlayerView()

            case .record:
                RecordView()
            }
        }
        .animation(.snappy(duration: 0.35), value: appState.playerMode)
    }
}
