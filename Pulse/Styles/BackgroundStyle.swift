//
//  BackgroundStyle.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//


import SwiftUI

enum BackgroundStyle: String, CaseIterable, Codable {

    case clear
    case darkClear
    case artworkTint
    case adaptive

    var title: String {
        switch self {
        case .clear:
            return "Clear Light"

        case .darkClear:
            return "Clear Dark"

        case .artworkTint:
            return "Album Colors"

        case .adaptive:
            return "Adaptive"
        }
    }
}
