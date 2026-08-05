//
//  HoverButtonStyle.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//


import SwiftUI

struct HoverButtonStyle: ButtonStyle {

    @State private var hovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25), value: configuration.isPressed)
    }
}
