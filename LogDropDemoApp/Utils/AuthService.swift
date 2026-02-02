//
//  AuthService.swift
//  LogDropDemoApp
//
//  Created by Initial Code Software Solutions on 30.01.2026.
//

import Foundation

final class AuthService {
    func login(username: String, password: String) async throws -> AuthToken {
        let url = URL(string: "\(Environment.API.baseURL)/auth/login")!
        
        let loginData = LoginRequest(username: username, password: password)
        
        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: loginData
        )
    }
}
