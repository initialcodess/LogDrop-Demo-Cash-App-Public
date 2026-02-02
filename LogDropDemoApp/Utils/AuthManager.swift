//
//  AuthManager.swift
//  LogDropDemoApp
//
//  Created by Initial Code Software Solutions on 30.01.2026.
//
import Foundation


@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false

    private let tokenStore = TokenStore()

    init() {
        isAuthenticated = tokenStore.accessToken != nil
    }

    func login(token: AuthToken) {
        tokenStore.accessToken = token.accessToken
        isAuthenticated = true
    }

    func logout() {
        tokenStore.clear()
        isAuthenticated = false
    }
}
