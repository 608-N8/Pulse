//
//  PulseGlassButtonStyle.swift
//  Pulse
//
//  Created by Nate Patton on 8/4/26.
//

import SwiftUI

struct PulseGlassButtonStyle: ButtonStyle {

    let tint: Color
    
    let width: Double
    let height: Double

    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .foregroundStyle(.foreground)
            .shadow(color: tint.opacity(0.8), radius: 2, x:0, y:0)
            .frame(width: width, height: height)
            .contentShape(Circle())
            .glassEffect(.regular.interactive())
            .overlay {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 0.5)

                Circle()
                    .stroke(tint, lineWidth: 1)
                    .padding(0.5)
            }
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.snappy, value: configuration.isPressed)
    }
}
