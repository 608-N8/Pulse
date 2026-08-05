//
//  MarqueeText.swift
//  Pulse
//
//  Created by Nate Patton on 8/4/26.
//

import SwiftUI

struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: CGFloat
    let delay: Double

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var marqueeTask: Task<Void, Never>?

    init(
        _ text: String,
        font: Font = .body,
        speed: CGFloat = 35,
        delay: Double = 1.5
    ) {
        self.text = text
        self.font = font
        self.speed = speed
        self.delay = delay
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Text(text)   // Invisible text used for sizing
                    .font(font)
                    .fixedSize()
                    .hidden()
                    .background(
                        GeometryReader { textGeo in
                            Color.clear
                                .onAppear {
                                    textWidth = textGeo.size.width
                                    containerWidth = geo.size.width
                                    startAnimation()
                                }
                                .onChange(of: textGeo.size.width) { _, newWidth in
                                    textWidth = newWidth
                                    startAnimation()
                                }
                        }
                    )
                
                Text(text) // Visible text to be scrolled
                    .font(font)
                    .lineLimit(1)
                    .offset(x: offset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .onAppear {
                containerWidth = geo.size.width
                startAnimation()
            }
            .onChange(of: geo.size.width) { _, newWidth in
                containerWidth = newWidth
                startAnimation()
            }
            .onChange(of: text) { _, _ in
                offset = 0
                DispatchQueue.main.async {
                    startAnimation()
                }
            }
            .onDisappear {
                marqueeTask?.cancel()
            }
        }
        .frame(maxHeight: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func startAnimation() {  // The scrolling animation
        marqueeTask?.cancel()
        
        guard textWidth > containerWidth else {
            offset = 0
            return
        }
        
        let distance = textWidth - containerWidth
        let duration = distance / speed
        marqueeTask = Task {
            while !Task.isCancelled {
                await MainActor.run {
                    offset = 0
                }
                try? await Task.sleep(for: .seconds(delay))
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    withAnimation(.linear(duration: duration)) {
                        offset = -distance
                    }
                }
                try? await Task.sleep(for: .seconds(duration + delay))
            }
        }
    }
}
