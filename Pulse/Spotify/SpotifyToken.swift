//
//  SpotifyToken.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import Foundation

struct SpotifyToken: Codable {

    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String?
}
