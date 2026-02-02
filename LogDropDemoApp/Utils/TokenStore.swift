//
//  TokenStore.swift
//  LogDropDemoApp
//
//  Created by Initial Code Software Solutions on 30.01.2026.
//


final class TokenStore {
    private let keychain = KeychainService.shared
    private let accessTokenKey = "access_token"

    var accessToken: String? {
        get {
            keychain.read(key: accessTokenKey)
        }
        set {
            if let token = newValue {
                keychain.save(token, for: accessTokenKey)
            } else {
                keychain.delete(key: accessTokenKey)
            }
        }
    }

    func clear() {
        accessToken = nil
    }
}
