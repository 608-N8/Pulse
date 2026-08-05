//
//  SpotifyPlayback.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import Foundation

struct SpotifyPlayback: Decodable {

    let isPlaying: Bool
    let progressMS: Double
    let item: Item?

    enum CodingKeys: String, CodingKey {
        case isPlaying = "is_playing"
        case progressMS = "progress_ms"
        case item
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        isPlaying = try container.decodeIfPresent(
            Bool.self,
            forKey: .isPlaying
        ) ?? false

        progressMS = try container.decodeIfPresent(
            Double.self,
            forKey: .progressMS
        ) ?? 0

        item = try container.decodeIfPresent(
            Item.self,
            forKey: .item
        )
    }
    
    struct Item: Decodable {

        let name: String
        let durationMS: Double
        let artists: [Artist]
        let album: Album

        enum CodingKeys: String, CodingKey {
            case name
            case durationMS = "duration_ms"
            case artists
            case album
        }
    }

    struct Artist: Decodable {
        let name: String
    }

    struct Album: Decodable {
        let images: [Image]
    }

    struct Image: Decodable {
        let url: String
    }

}
