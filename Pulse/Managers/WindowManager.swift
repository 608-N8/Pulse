//
//  WindowManager.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import SwiftUI
import AppKit
import Combine

final class WindowManager: ObservableObject {

    weak var window: NSWindow?
    private var hasSetup = false
    
    func setMode(_ mode: PlayerMode) {
        animateWindow(width: mode.size.width, height: mode.size.height) // Calls the animate window function to change sizes
    }
    
    func animateWindow(width: CGFloat, height: CGFloat) {  // Animates the windows size to the new window size
        guard let window else { return }
        
        var frame = window.frame

        let newOrigin = CGPoint(
            x: frame.origin.x,
            y: frame.origin.y + (frame.height - height)
        )

        frame.origin = newOrigin
        frame.size = CGSize(width: width, height: height)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.35
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(frame, display: true)
        }
    }

    func setupMainWindow() {
        guard !hasSetup else { return }
        
        hasSetup = true

        guard let window = NSApplication.shared.windows.first else { return }

        self.window = window
        window.styleMask = [.borderless] // Makes the window borderless
        window.backgroundColor = .clear // Hides the default window background
        window.isOpaque = false // Decoration
        window.hasShadow = true // Decoration
        window.level = .floating // Makes the window apear on top
        window.isMovableByWindowBackground = true // Makes the whole window draggable
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.setContentSize(CGSize(width: 360, height: 110)) // Sets the windows default size
    }
}
