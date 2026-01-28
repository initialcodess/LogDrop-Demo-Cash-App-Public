//
//  LogDropLogger.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import Foundation
import LogDropSDK

/**
 This helper class manages LogFlow objects and provides simple logging methods.
 
 You can set a global LogFlow to be used across the app.
 For one-off flows, you can pass a LogFlow object directly to the logging methods.
 
This prevents creating a new flow ID for every log and keeps related logs grouped under the same flow.
 */
final class LogDropLogger {
    static let shared = LogDropLogger()
    
    // Global LogFlow for the app
    private var currentLogFlow: LogFlow?

    private init() {}

    // Set a global LogFlow for all future logs
    func setGlobalFlow(_ logFlow: LogFlow?) {
        currentLogFlow = logFlow
    }

    // Clear the global LogFlow
    func clearGlobalFlow() {
        currentLogFlow = nil
    }

    func logInfo(_ message: String, logFlow: LogFlow? = nil) {
        LogDrop.i(message, logFlow: logFlow ?? currentLogFlow)
    }

    func logWarning(_ message: String, logFlow: LogFlow? = nil) {
        LogDrop.w(message, logFlow: logFlow ?? currentLogFlow)
    }

    func logError(_ message: String, logFlow: LogFlow? = nil) {
        LogDrop.e(message, logFlow: logFlow ?? currentLogFlow)
    }

    func logDebug(_ message: String, logFlow: LogFlow? = nil) {
        LogDrop.d(message, logFlow: logFlow ?? currentLogFlow)
    }
}
