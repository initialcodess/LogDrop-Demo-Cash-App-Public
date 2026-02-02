//
//  APIClient.swift
//  LogDropDemoApp
//
//  Created by Initial Code Software Solutions on 30.01.2026.
//

import Foundation

final class APIClient {
    static let shared = APIClient()
    private let tokenStore = TokenStore()
    
    func request<T: Decodable, B: Encodable>(
        url: URL,
        method: String = "GET",
        body: B? = nil
    ) async throws -> T {
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = tokenStore.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 401 {
            throw URLError(.userAuthenticationRequired)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let message: String
            if let errorObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let serverMessage = errorObj["message"] as? String {
                message = serverMessage
            } else if let serverMessage = String(data: data, encoding: .utf8) {
                message = serverMessage
            } else {
                message = "An unknown error occurred"
            }
            
            LogDropLogger.shared.logError("Request failed: \(message)")
            
            throw BackendError(message: message)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func request<T: Decodable>(
        url: URL,
        method: String = "GET"
    ) async throws -> T {
        let emptyBody: String? = nil
        return try await request(url: url, method: method, body: emptyBody)
    }
}
