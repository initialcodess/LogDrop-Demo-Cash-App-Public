//
//  HomeView.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import SwiftUI
import LogDropSDK

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager

    @ObservedObject private var router = CashAppRouter.shared
    @State private var showProfile = false
    @State private var showAddMoney = false
    @State private var dashboard: DashboardResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?


    var body: some View {
        TabView(selection: $router.tab) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        LogDropLogger.shared.logInfo("User tapped on profile icon")
                        showProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button(action: {
                        LogDropLogger.shared.logDebug("Settings button tapped")
                        showProfile = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CURRENT ACCOUNT")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("$\(dashboard?.account.balance ?? "0")")
                                .font(.system(size: 32, weight: .bold))
                                .onAppear {
                                    LogDropLogger.shared.logInfo("Balance displayed: $\(dashboard?.account.balance ?? "0")")
                                }

                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [.black, Color("PrimaryColor")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(height: 180)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dashboard?.cards.first?.cardNumber ?? "**** **** **** ****")
                                        .foregroundColor(.white)
                                    Text(dashboard?.cards.first?.cardHolder ?? "-")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.caption)
                                    Text(dashboard?.cards.first?.expiryDate ?? "--/--")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.caption)
                                }
                                .padding()
                            }
                            .overlay(
                                Image("AppLogoVector")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 30)
                                    .padding([.bottom, .trailing], 12),
                                alignment: .bottomTrailing
                            )
                        }
                        .padding(.horizontal)

                        HStack {
                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text("Current Account")
                                        .font(.subheadline)
                                        .bold()
                                    Text("\(dashboard?.account.accountNumber ?? "No account")")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Button("Manage") {
                                LogDropLogger.shared.logInfo("Manage button tapped")
                                simulateApiCall()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)

                        Button { showAddMoney = true } label: {
                            PaymentActionRow(icon: "plus.circle.fill", title: "Add money", subtitle: "Top up your cash account", color: Color("PrimaryColor"))
                        }
                        .background(Color.white).cornerRadius(12).shadow(radius: 1).padding(.horizontal)

                        HStack {
                            Text("Transactions")
                                .font(.headline)
                                .onAppear {
                                    LogDropLogger.shared.logDebug("Transactions list appeared")
                                }
                            Spacer()
                            Button("See All") {
                                LogDropLogger.shared.logInfo("See All transactions tapped")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)

                        VStack(spacing: 16) {
                            ForEach(dashboard?.transactions.prefix(10) ?? [], id: \.id) { transaction in
                                TransactionRow(
                                    icon: transaction.type == "EXPENSE" ? "tray.full.fill" : "dollarsign.circle.fill",
                                    title: transaction.title,
                                    type: transaction.type,
                                    amount: transaction.type == "EXPENSE"
                                        ? "-$\(transaction.amount)"
                                        : "+$\(transaction.amount)",
                                    amountColor: transaction.type == "EXPENSE" ? .black : .green
                                )
                            }
                        }
                        .padding(.horizontal)

                    }
                    .padding(.top, 16)
                }
            }
            .onAppear {
                LogDropLogger.shared.logInfo("Home screen opened")
                loadDashboard()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }.tag(0)

            PaymentsView()
                .onAppear {
                    LogDropLogger.shared.logDebug("Payments screen opened")
                }
                .tabItem {
                    Label("Payments", systemImage: "arrow.right.arrow.left")
                }.tag(1)

            CashOffersView()
                .tabItem { Label("Offers", systemImage: "sparkles") }.tag(2)

            Button("Exit") {
                LogDropLogger.shared.logWarning("Exit tapped, logging out")
                authManager.logout()
            }
            .tabItem {
                Label("Exit", systemImage: "questionmark.circle")
            }.tag(3)
        }
        .tint(Color("PrimaryColor"))
        .sheet(isPresented: $showProfile) { CashProfileView() }
        .sheet(isPresented: $showAddMoney, onDismiss: { loadDashboard() }) { CashAddMoneyView() }
        .task {
            do {
                let profile: CashProfile = try await APIClient.shared.request(url: URL(string: "\(Environment.API.baseURL)/demo/profile")!)
                LogDrop.updateUser(userUuid: profile.username) { result in
                    if case .success = result { profile.syncAttributes() }
                }
            } catch { LogDropLogger.shared.logWarning("Could not sync account preferences: \(error.localizedDescription)") }
        }
    }

    private func simulateApiCall() {
        LogDropLogger.shared.logDebug("API request started: POST /v1/account/manage")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            LogDropLogger.shared.logError("API request failed: \(DummyData.failedApiResponse)")
        }
    }

    private func loadDashboard() {
        Task {
            do {
                let url = URL(string: "\(Environment.API.baseURL)/dashboard")!
                let response: DashboardResponse = try await APIClient.shared.request(url: url)

                await MainActor.run {
                    self.dashboard = response
                    self.isLoading = false
                }

                LogDropLogger.shared.logInfo("Dashboard data loaded successfully")

            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Dashboard could not be loaded"
                }

                LogDropLogger.shared.logError("Dashboard request failed: \(error.localizedDescription)")
            }
        }
    }

}

struct TransactionRow: View {
    var icon: String
    var title: String
    var type: String
    var amount: String
    var amountColor: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                Text(type)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(amount)
                .foregroundColor(amountColor)
                .bold()
        }
    }
}

#Preview {
    HomeView()
}
