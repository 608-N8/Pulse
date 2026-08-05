//
//  PulseSlider.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import SwiftUI

struct PulseSlider: View {

    @Binding var value: Double
    let range: ClosedRange<Double>
    var height: CGFloat = 8
    var trackTint: Color = .white.opacity(0.15)
    var progressTint: Color = .white.opacity(0.45)
    var onChanged: ((Double) -> Void)? = nil

    private var progress: Double {
        guard range.upperBound > range.lowerBound else {
            return 0
        }

        return (value - range.lowerBound) /
        (range.upperBound - range.lowerBound)
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            
            ZStack(alignment: .leading) {
                // MARK: - Track for the Pulse Slider
                Capsule()
                    .fill(.clear)
                    .glassEffect(.regular.interactive())
                    .frame(height: height)
                    .overlay {
                            Capsule()
                                .stroke(
                                    progressTint.opacity(0.9),
                                    lineWidth: 0.5
                                )
                        }
                // MARK: - Fill for the Pulse Slider
                Capsule()
                    .fill(.clear)
                    .glassEffect(.regular.interactive())
                    .frame(
                        width: width * progress,
                        height: height
                    )
                    .overlay {
                        Capsule()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                        Capsule()
                            .stroke(progressTint.opacity(0.9), lineWidth: 1)
                            .padding(0.5)
                    }
            }
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture()
                    .onEnded { tap in
                        let percent = min(
                            max(tap.location.x / width, 0),
                            1
                        )
                        value = range.lowerBound +
                            percent *
                            (range.upperBound - range.lowerBound)
                        onChanged?(value)
                    }
            )
        }
        .frame(height: height)
    }
}
