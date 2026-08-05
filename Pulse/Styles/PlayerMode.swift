//
//  PlayerMode.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//


import Foundation

enum PlayerMode: String, CaseIterable, Codable {

    case compact
    case controls
    case expanded
    case record

    var size: CGSize {
        switch self {
        case .compact:
            return CGSize(width: 180, height: 110)
        case .controls:
            return CGSize(width: 360, height: 110)
        case .expanded:
            return CGSize(width: 400, height: 480)
        case .record:
            return CGSize(width: 500, height: 500)
        }
    }
}
