//
//  LoginView.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import SwiftUI
import LogDropSDK
struct LoginView: View {

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 100)

            Spacer()
        }
        .padding(.horizontal, 24)

    }

}

#Preview {
    LoginView()
}
