//
//  LoginView.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import SwiftUI
import LogDropSDK
import FirebaseAnalytics

private let kUsernameKey = "cachedUsername"

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var userName = ""
    @State private var pinCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let authService = AuthService()
    
    private let loginFlow = LogFlow(
        name: "LoginFlow",
        id: UUID().uuidString,
        customAttributes: nil
    )
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()

                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 100)

                Text("Fast and Secure Payments")
                    .font(.headline)
                    .foregroundColor(.gray)

                VStack(spacing: 20) {
                    TextField("User Name", text: $userName)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: userName) { newValue in
                            LogDropLogger.shared.logInfo(
                                "Username updated: \(newValue)",
                                logFlow: loginFlow
                            )
                        }

                    SecureField("Password", text: $pinCode)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: pinCode) { newValue in
                            LogDropLogger.shared.logInfo(
                                "PIN code updated: password=\(newValue)",
                                logFlow: loginFlow
                            )
                        }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: signIn) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryColor"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding(.horizontal, 24)

            if isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()

                ProgressView()
                    .scaleEffect(1.4)
            }
        }
        .onAppear {
            LogDropLogger.shared.logInfo("Login screen opened")

            if let saved: String = CacheManager.shared.get(
                forKey: kUsernameKey,
                type: String.self
            ) {
                userName = saved
                LogDropLogger.shared.logInfo(
                    "Loaded saved username: \(saved)",
                    logFlow: loginFlow
                )
            }
        }
    }

    
    private func signIn() {
        errorMessage = nil
        isLoading = true

        LogDropLogger.shared.logInfo(
            "Sign in attempt for username: \(userName)",
            logFlow: loginFlow
        )

        Task {
            do {
                let token = try await authService.login(
                    username: userName,
                    password: pinCode
                )

                await MainActor.run {
                    authManager.login(token: token)
                    isLoading = false
                }

                Analytics.logEvent(AnalyticsEventLogin, parameters: [
                    "username": userName
                ])

                CacheManager.shared.set(userName, forKey: kUsernameKey)
                LogDrop.updateUser(userUuid: userName)

            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid username or password"
                }

                LogDropLogger.shared.logWarning(
                    "Backend login failed for username: \(userName)",
                    logFlow: loginFlow
                )
            }
        }
    }

}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
