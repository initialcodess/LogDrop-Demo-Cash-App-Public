//
//  LoginView.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import SwiftUI
import LogDropSDK

private let kUsernameKey = "cachedUsername"

struct LoginView: View {
    @State private var userName = ""
    @State private var pinCode = ""
    @State private var showError = false

    private let loginFlow = LogFlow(
        name: "LoginFlow",
        id: UUID().uuidString,
        customAttributes: nil
    )

    var body: some View {
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
                        LogDropLogger.shared.logInfo("Username updated: \(newValue)", logFlow: loginFlow)
                    }

                SecureField("PIN Code", text: $pinCode)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: pinCode) { newValue in
                        // The "password" value here will be masked in logs
                        // because of the SensitiveInfoFilter added in LogDropConfig
                        LogDropLogger.shared.logInfo("PIN code updated: password=\(newValue)", logFlow: loginFlow)
                    }
            }

            if showError {
                Text("Invalid credentials")
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
        .onAppear {
            LogDropLogger.shared.logInfo("Login screen opened")

            // Load cached username if available
            if let saved: String = CacheManager.shared.get(forKey: kUsernameKey, type: String.self) {
                userName = saved
                LogDropLogger.shared.logInfo("Loaded saved username: \(saved)", logFlow: loginFlow)
            }
        }
    }

    private func signIn() {
        LogDropLogger.shared.logInfo("Sign in attempt for username: \(userName)", logFlow: loginFlow)

        if pinCode == DummyData.pinCode {
            showError = false
            CacheManager.shared.set(userName, forKey: kUsernameKey)
            LogDrop.updateUser(userUuid: userName)
            LogDropLogger.shared.logInfo("Sign in successful for username: \(userName)", logFlow: loginFlow)
            // Navigate to next screen
        } else {
            showError = true
            LogDropLogger.shared.logWarning("Sign in failed for username: \(userName)", logFlow: loginFlow)
        }
    }
}

#Preview {
    LoginView()
}
