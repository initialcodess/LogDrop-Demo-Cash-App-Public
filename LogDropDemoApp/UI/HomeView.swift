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
    var body: some View {
        TabView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        LogDropLogger.shared.logInfo("User tapped on profile icon")
                        fatalError("unexpected nil value while loading profile")
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                    
                    Button(action: {
                        LogDropLogger.shared.logDebug("Settings button tapped")
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
                            
                            Text("$2,985.43")
                                .font(.system(size: 32, weight: .bold))
                                .onAppear {
                                    LogDropLogger.shared.logInfo("Balance displayed: $2,985.43")
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
                                    Text("**** **** **** 2025")
                                        .foregroundColor(.white)
                                    Text("Kvothe Rofthuss")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.caption)
                                    Text("02/28")
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
                                    Text("•••• 2025")
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
                            TransactionRow(
                                icon: "tray.full.fill",
                                title: "LogDrop Subscription",
                                type: "Expense",
                                amount: "-$19.99",
                                amountColor: .black
                            )

                            TransactionRow(
                                icon: "dollarsign.circle.fill",
                                title: "Salary",
                                type: "Income",
                                amount: "+$6,300.00",
                                amountColor: .green
                            )

                            TransactionRow(
                                icon: "wifi",
                                title: "Internet",
                                type: "Expense",
                                amount: "-$29.99",
                                amountColor: .black
                            )
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding(.top, 16)
                }
            }
            .onAppear {
                LogDropLogger.shared.logInfo("Home screen opened")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            PaymentsView()
                .onAppear {
                    LogDropLogger.shared.logDebug("Payments screen opened")
                }
                .tabItem {
                    Label("Payments", systemImage: "arrow.right.arrow.left")
                }

            Text("Exit Screen")
                .onAppear {
                    LogDropLogger.shared.logWarning("Exit screen opened")
                }
                .tabItem {
                    Label("Exit", systemImage: "questionmark.circle")
                }
        }
    }
    
    private func simulateApiCall() {
        LogDropLogger.shared.logDebug("API request started: POST /v1/account/manage")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            LogDropLogger.shared.logError("API request failed: \(DummyData.failedApiResponse)")
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
