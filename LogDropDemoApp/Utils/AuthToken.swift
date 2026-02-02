//
//  AuthToken.swift
//  LogDropDemoApp
//
//  Created by Initial Code Software Solutions on 30.01.2026.
//


struct AuthToken: Codable {
    let accessToken: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case username
    }
}
