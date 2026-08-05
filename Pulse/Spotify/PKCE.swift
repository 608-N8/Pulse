//
//  PKCE.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import Foundation
import CryptoKit

struct PKCE {

    let verifier: String
    let challenge: String

    init() {
        verifier = Self.randomVerifier()
        challenge = Self.challenge(from: verifier)
    }

    private static func randomVerifier(length: Int = 64) -> String {
        let characters = Array(
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        )
        var verifier = ""

        for _ in 0..<length {
            verifier.append(characters.randomElement()!)
        }

        return verifier
    }

    private static func challenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)

        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
