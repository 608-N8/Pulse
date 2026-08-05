//
//  SpotifyAuthManager.swift
//  Pulse
//
//  Created by Nate Patton on 8/3/26.
//

import Combine
import Foundation
import AppKit

@MainActor
final class SpotifyAuthManager: ObservableObject {

    static let shared = SpotifyAuthManager()

    @Published var accessToken: String?
    @Published var isAuthenticated = false

    private let clientID = "c359933d65194ad190a5cdb569248586"
    private let redirectURI = "pulse://callback"

    private var pkce = PKCE()
    
    private var refreshToken: String? {
        KeychainManager.shared.get("spotify_refresh_token")
    }
    
    // MARK: - Pulse access points
    private let scopes = [
        "user-read-playback-state",
        "user-modify-playback-state",
        "user-read-currently-playing",
        "user-read-email",
        "user-read-private"
    ]
    
    // MARK: - Sign in to give Pulse access to your spotify account
    func signIn() {

        pkce = PKCE()

        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!

        components.queryItems = [

            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: pkce.challenge)

        ]

        guard let url = components.url else { return }

        NSWorkspace.shared.open(url)

    }
    
    // MARK: - Resets your saved Spotify account from the Pulse app
    func resetAuthentication() {

        accessToken = nil
        isAuthenticated = false

        UserDefaults.standard.removeObject(forKey: "spotify_access_token")
        UserDefaults.standard.removeObject(forKey: "spotify_refresh_token")
        UserDefaults.standard.removeObject(forKey: "spotify_token_expiration")

        KeychainManager.shared.delete("spotify_access_token")
        KeychainManager.shared.delete("spotify_refresh_token")

    }
    
    // MARK: - Restores Pulse to your Spotify account so you dont need to login again
    func restoreSession() {

        guard refreshToken != nil else {
            print("No refresh token found.")
            return
        }

        Task {
            await refreshAccessToken()
        }

    }
    
    // MARK: - Get a new access token
    private func refreshAccessToken() async {

        guard
            let refreshToken,
            let url = URL(string: "https://accounts.spotify.com/api/token")
        else {
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        let body = [
            "client_id=\(clientID)",
            "grant_type=refresh_token",
            "refresh_token=\(refreshToken)"
        ].joined(separator: "&")

        request.httpBody = body.data(using: .utf8)

        do {

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                return
            }

            print("Refresh Status:", http.statusCode)

            guard http.statusCode == 200 else {

                print(String(decoding: data, as: UTF8.self))
                return

            }

            let token = try JSONDecoder().decode(
                SpotifyToken.self,
                from: data
            )

            accessToken = token.access_token
            isAuthenticated = true

            KeychainManager.shared.save(
                token.access_token,
                for: "spotify_access_token"
            )

            print("Session restored!")

        } catch {

            print(error)

        }

    }

    // MARK: - Handles the redirect and sends the code
    func handleRedirect(_ url: URL) {

        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            print("No authorization code.")
            return
        }

        Task {
            await exchangeCodeForToken(code)
        }

    }
    
    // MARK: - Exchanges the code for the token
    private func exchangeCodeForToken(_ code: String) async {

        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        let body = [
            "client_id=\(clientID)",
            "grant_type=authorization_code",
            "code=\(code)",
            "redirect_uri=\(redirectURI)",
            "code_verifier=\(pkce.verifier)"
        ]
        .joined(separator: "&")

        request.httpBody = body.data(using: .utf8)

        do {

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                return
            }

            print("Status:", http.statusCode)

            print(String(decoding: data, as: UTF8.self))

            if http.statusCode != 200 {
                return
            }

            let token = try JSONDecoder().decode(SpotifyToken.self, from: data)

            accessToken = token.access_token
            isAuthenticated = true

            KeychainManager.shared.save(token.access_token, for: "spotify_access_token")

            if let refresh = token.refresh_token {
                KeychainManager.shared.save(refresh, for: "spotify_refresh_token")
            }

            print("Logged in!")

        } catch {

            print(error)

        }

    }

}
