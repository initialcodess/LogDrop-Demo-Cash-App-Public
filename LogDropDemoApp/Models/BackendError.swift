//
//  BackendError.swift
//  LogDropDemoApp
//
//  Created by Initial Code Software Solutions on 30.01.2026.
//

import Foundation

struct BackendError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
