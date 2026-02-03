//
//  PaymentsView.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import SwiftUI
import LogDropSDK
import Foundation

struct PaymentsView: View {
    @State private var flowUuid: String = ""
    @State private var showSheet = false
    @State private var username = ""
    @State private var message = ""
    @State private var amount = ""

    @State private var balance: Double = 0.0
    @State private var payableUsers: [PayableUser] = []
    @State private var isLoading = false

    @State private var errorMessage: String? = nil
    @State private var isProcessing = false

    @State private var showSuccessToast = false
    @State private var toastMessage = ""

    private let sendFundsFlow = LogFlow(
        name: "SendFundsFlow",
        id: UUID().uuidString,
        customAttributes: nil
    )

    private func performTransfer() {
        let amountInt = Int(amount) ?? 0
        let transferData = TransferRequest(
            receiverUsername: username,
            amount: amountInt,
            message: message
        )

        isProcessing = true
        errorMessage = nil

        LogDropLogger.shared.logInfo(
            "Transfer request initiated for \(username) with amount \(amount)",
            logFlow: sendFundsFlow
        )
        let url = URL(string: "\(Environment.API.baseURL)/transactions/transfer")!

        Task {
            do {
                let _: TransferResponse = try await APIClient.shared.request(
                    url: url,
                    method: "POST",
                    body: transferData
                )

                await MainActor.run {
                    isProcessing = false
                    showSheet = false
                    fetchDashboardData()
                }

                self.toastMessage = "Transfer to \(username) successful!"
                    withAnimation {
                        self.showSuccessToast = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.showSuccessToast = false
                        }
                    }

            } catch let error as BackendError {
                await MainActor.run {
                    self.errorMessage = error.message
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                }
            }
        }
    }



    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                HStack {
                    TextField("Set Flow UUID", text: $flowUuid)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    /**
                     DEMO only:
                     This UI lets us set a global flow id for logs.
                     In real apps, flows are set by developers in code.
                     If input is empty, the global flow is cleared (nil).
                     */
                    Button("Set") {
                        if flowUuid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            LogDropLogger.shared.setGlobalFlow(nil)
                            LogDropLogger.shared.logInfo("Global flow cleared")
                        } else {
                            let newFlow = LogFlow(
                                name: flowUuid,
                                id: UUID().uuidString,
                                customAttributes: nil
                            )
                            LogDropLogger.shared.setGlobalFlow(newFlow)
                            LogDropLogger.shared.logInfo("Global flow set with id: \(flowUuid)")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color("PrimaryColor"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("ALL ACCOUNTS")
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack {
                        Image(systemName: "creditcard.fill")
                            .resizable()
                            .frame(width: 32, height: 24)
                            .foregroundColor(Color("PrimaryColor"))
                        VStack(alignment: .leading) {
                            Text("All Accounts")
                                .font(.subheadline)
                                .bold()
                            Text("$\(String(format: "%.2f", balance))")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                VStack(spacing: 0) {
                    Button(action: {
                        LogDropLogger.shared.logInfo("Send Funds tapped")
                        showSheet = true
                    }) {
                        PaymentActionRow(
                            icon: "arrow.up.right.circle.fill",
                            title: "Send Funds",
                            subtitle: "Via transfer or payment link",
                            color: .green
                        )
                    }
                    .sheet(isPresented: $showSheet) {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Button(action: {
                                    LogDropLogger.shared.logInfo("Send Funds sheet closed", logFlow: sendFundsFlow)
                                    showSheet = false
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                Text("Send Funds")
                                    .font(.title2).bold()
                                Spacer()
                                Color.clear.frame(width: 24, height: 24)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("USERNAME")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("Enter username", text: $username)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .autocapitalization(.none)
                            }

                            TextField("Add a message", text: $message)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("AMOUNT")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("$0.00", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 36, weight: .semibold))
                                    .padding(.vertical, 8)
                            }
                            .padding(.vertical, 8)

                            Spacer()

                            if let error = errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text(error)
                                }
                                .font(.callout)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            }

                            Button(action: {
                                LogDropLogger.shared.logInfo(
                                    "Send button tapped by user",
                                    logFlow: sendFundsFlow
                                )
                                performTransfer()
                            }) {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Send \(amount.isEmpty ? "$0.00" : "$\(amount)")")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            .disabled(isProcessing || username.isEmpty || amount.isEmpty)
                        }
                        .padding()
                        .onDisappear {
                            username = ""
                            amount = ""
                            message = ""
                            errorMessage = nil
                        }
                    }

                    Divider()

                    Button(action: {
                        LogDropLogger.shared.logError("Receive Funds request failed: No valid account linked")
                    }) {
                        PaymentActionRow(
                            icon: "arrow.down.left.circle.fill",
                            title: "Receive Funds",
                            subtitle: "Request a payment from others",
                            color: .blue
                        )
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Pay Fast")
                        .font(.headline)
                        .padding(.horizontal)

                    if isLoading {
                        ProgressView()
                            .padding(.horizontal)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(payableUsers) { user in
                                    VStack {
                                        Circle()
                                            .fill(Color("PrimaryColor"))
                                            .frame(width: 56, height: 56)
                                            .overlay(Text(String(user.username.prefix(1)).uppercased())
                                                .foregroundColor(.white)
                                                .font(.headline))
                                        Text(user.username)
                                            .font(.caption)
                                    }
                                    .onTapGesture {
                                        LogDropLogger.shared.logInfo("Pay Fast tapped for user: \(user.username)")
                                        self.username = user.username
                                        self.showSheet = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Payments")

            // MARK: Success Toast UI
            if showSuccessToast {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                    Text(toastMessage)
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .bold()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.green)
                .cornerRadius(25)
                .shadow(radius: 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 10)
                .zIndex(1)
            }
        }
        .navigationTitle("Payments")
        .onAppear {
            LogDropLogger.shared.logInfo("Payments screen opened")
            fetchDashboardData()
        }
    }

    private func fetchDashboardData() {
        guard let url = URL(string: "\(Environment.API.baseURL)/payment/dashboard") else { return }

        isLoading = true
        Task {
            do {
                let response: PaymentDashboardResponse = try await APIClient.shared.request(url: url)
                await MainActor.run {
                    self.balance = response.balanceDouble
                    self.payableUsers = response.payableUsers
                    self.isLoading = false
                }
            } catch {
                LogDropLogger.shared.logError("Failed to fetch dashboard: \(error.localizedDescription)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

struct PaymentActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(color)
            VStack(alignment: .leading) {
                Text(title).font(.body).bold()
                Text(subtitle).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    PaymentsView()
}
