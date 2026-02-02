//
//  PaymentDashboardResponse.swift
//  LogDropDemoApp
//
//  Created by Initial Code Software Solutions on 30.01.2026.
//


struct PaymentDashboardResponse: Decodable {
    let balance: String
    let payableUsers: [PayableUser]
    
    var balanceDouble: Double {
        Double(balance) ?? 0.0
    }
}

struct PayableUser: Decodable, Identifiable {
    let id: String
    let username: String
    let account: AccountInfo?
    
    struct AccountInfo: Decodable {
        let accountNumber: String
    }
}
