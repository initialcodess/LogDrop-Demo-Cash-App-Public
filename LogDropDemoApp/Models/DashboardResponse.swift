//
//  DashboardResponse.swift
//  LogDropDemoApp
//
//  Created by Initial Code Software Solutions on 30.01.2026.
//


import Foundation

struct DashboardResponse: Decodable {
    let account: AccountDTO
    let cards: [CardDTO]
    let transactions: [TransactionDTO]
}

struct AccountDTO: Decodable {
    let accountNumber: String
    let balance: String
}

struct CardDTO: Decodable {
    let id: String
    let cardNumber: String
    let cardHolder: String
    let expiryDate: String
    let accountId: String
}

struct TransactionDTO: Decodable {
    let id: String
    let title: String
    let amount: String
    let type: String
    let date: String
    let accountId: String
}
