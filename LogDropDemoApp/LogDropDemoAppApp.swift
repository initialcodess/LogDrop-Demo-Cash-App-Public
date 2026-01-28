//
//  LogDropDemoAppApp.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import SwiftUI
import LogDropSDK

@main
struct LogDropDemoAppApp: App {
    @StateObject private var session = SessionManager()

    init() {
        let config = LogDropConfig.Builder()
            .setBaseUrl("")
            .setApiKey("")
            .setLoggingEnabled(true)
            .setCrashTrackingEnabled(true)
            .setSensitiveInfoFilter(sensitiveInfoFilter: [
                try! NSRegularExpression(pattern: "^cardNo:\\s(?:\\d{4}[-\\s]?){3}\\d{4}$"),
                try! NSRegularExpression(pattern: "password=[^&\\s]+")
            ])
            .build()

        LogDrop.initialize(with: config)
    }
    
    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                HomeView()
                    .environmentObject(session)
            } else {
                LoginView()
                    .environmentObject(session)
            }
        }
    }
}
