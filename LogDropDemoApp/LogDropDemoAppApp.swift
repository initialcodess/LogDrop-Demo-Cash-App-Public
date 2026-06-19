//
//  LogDropDemoAppApp.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import SwiftUI
import LogDropSDK
import Firebase
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        LogDrop.onNewApnsToken(apnsToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LogDrop.onRemoteMessageReceived(userInfo)
        completionHandler(.newData)
    }
}

@main
struct LogDropDemoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authManager = AuthManager()

    init() {
        var appId = ""
        var baseUrl = ""
        
        if let path = Bundle.main.path(forResource: "LogDrop-Services", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            baseUrl = dict["base_url"] as? String ?? ""
            let projects = dict["projects"] as? [String: Any] ?? [:]
            let bundleId = Bundle.main.bundleIdentifier ?? ""
            if let projectDict = projects[bundleId] as? [String: Any],
               let loadedAppId = projectDict["app_id"] as? String {
                appId = loadedAppId
            }
        }
        
        let configBuilder = LogDropConfig.Builder()
            .setLoggingEnabled(true)
            
        if !appId.isEmpty {
            _ = configBuilder.setAppId(appId)
        }
        if !baseUrl.isEmpty {
            _ = configBuilder.setBaseUrl(baseUrl)
        }
        
        LogDrop.initialize(with: configBuilder.build())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
        }
    }
}


struct RootView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        if authManager.isAuthenticated {
            HomeView()
        } else {
            LoginView()
        }
    }
}
