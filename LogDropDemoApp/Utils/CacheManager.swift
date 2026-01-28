//
//  CacheManager.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import Foundation
import UIKit

final class CacheManager {
    static let shared = CacheManager()
    
    private init() {}
    
    func set<T: Codable>(_ value: T, forKey key: String) {
        if let encodedValue = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encodedValue, forKey: key)
        }
    }
    
    func get<T: Codable>(forKey key: String, type: T.Type) -> T? {
        if let data = UserDefaults.standard.data(forKey: key),
           let decodedValue = try? JSONDecoder().decode(T.self, from: data) {
            return decodedValue
        }
        return nil
    }
    
    func setBool(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getBool(forKey key: String, defaultValue: Bool) -> Bool {
        return UserDefaults.standard.object(forKey: key) as? Bool ?? defaultValue
    }
}
