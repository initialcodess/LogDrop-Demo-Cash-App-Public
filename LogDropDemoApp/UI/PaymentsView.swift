//
//  PaymentsView.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import SwiftUI
import LogDropSDK

struct PaymentsView: View {
    @State private var flowUuid: String = ""
    @State private var showSheet = false
    @State private var username = ""
    @State private var message = ""
    @State private var amount = ""
    
    private let sendFundsFlow = LogFlow(
        name: "SendFundsFlow",
        id: UUID().uuidString,
        customAttributes: nil
    )
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
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
                            Text("$7,325.29")
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
                    PaymentActionRow(
                        icon: "arrow.up.right.circle.fill",
                        title: "Send Funds",
                        subtitle: "Via transfer or payment link",
                        color: .green
                    )
                    .onTapGesture {
                        LogDropLogger.shared.logInfo("Send Funds tapped")
                        showSheet = true
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

                            Button(action: {
                                LogDropLogger.shared.logInfo(
                                    "Send Funds confirmed → username=\(username), amount=\(amount), message=\(message)",
                                    logFlow: sendFundsFlow
                                )
                                showSheet = false
                                username = ""
                                amount = ""
                                message = ""
                            }) {
                                Text("Send \(amount.isEmpty ? "$0.00" : "$\(amount)")")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    }

                    Divider()

                    PaymentActionRow(
                        icon: "arrow.down.left.circle.fill",
                        title: "Receive Funds",
                        subtitle: "Request a payment from others",
                        color: .blue
                    )
                    .onTapGesture {
                        LogDropLogger.shared.logError("Receive Funds request failed: No valid account linked")
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
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(DummyPayments.recentUsers, id: \.id) { user in
                                VStack {
                                    Circle()
                                        .fill(Color("PrimaryColor"))
                                        .frame(width: 56, height: 56)
                                        .overlay(Text(String(user.name.prefix(1)))
                                            .foregroundColor(.white)
                                            .font(.headline))
                                    Text(user.name)
                                        .font(.caption)
                                }
                                .onTapGesture {
                                    LogDropLogger.shared.logInfo("Pay Fast tapped for user: \(user.name)")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Payments")
        .onAppear {
            LogDropLogger.shared.logInfo("Payments screen opened")
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

struct DummyPayments {
    struct User: Identifiable {
        let id = UUID()
        let name: String
    }
    
    static let recentUsers = [
        User(name: "Liam"),
        User(name: "Olivia"),
        User(name: "Noah"),
        User(name: "Emma"),
        User(name: "Mason")
    ]
}

#Preview {
    PaymentsView()
}
