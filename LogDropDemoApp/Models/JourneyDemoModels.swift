import Foundation
import LogDropSDK

struct CashProfile: Codable {
    var username: String
    var accountTier: String
    var preferredCurrency: String
    func syncAttributes() {
        LogDrop.setCustomAttributes(["account_tier": accountTier, "preferred_currency": preferredCurrency])
    }
}
struct ProfileUpdate: Encodable { let accountTier: String; let preferredCurrency: String }
struct CashOffer: Decodable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let benefit: String
    let icon: String
    let category: String
    let detail: String
    let action: String
    var status: String
}
struct DemoSuccessResponse: Decodable { let success: Bool }
struct ApplicationUpdate: Encodable { let status: String }
struct ApplicationResponse: Decodable { let success: Bool; let status: String }
struct TopUpRequest: Encodable { let amount: Int }
struct TopUpResponse: Decodable { let success: Bool; let balance: Double }

final class CashAppRouter: ObservableObject, LogDropPushDeeplinkHandler, LogDropPushCallbacks {
    static let shared = CashAppRouter()
    @Published var tab = 0
    @Published var offerID: String?
    @Published var openBills = false

    @discardableResult
    func route(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "cashapp" else { return false }
        let destination = url.host?.lowercased()
        guard ["offers", "payments", "bills", "home"].contains(destination ?? "") else { return false }
        DispatchQueue.main.async {
            switch destination {
            case "offers":
                self.offerID = url.pathComponents.dropFirst().first
                self.tab = 2
            case "payments": self.tab = 1
            case "bills": self.tab = 1; self.openBills = true
            default: self.tab = 0
            }
        }
        return true
    }
    func handle(action: LogDropPushAction, push: LogDropPushPayload) -> Bool {
        guard let target = action.target, let url = URL(string: target) else { return false }
        return route(url)
    }
    func onNotificationOpened(push: LogDropPushPayload) {
        LogDropLogger.shared.logInfo("Customer opened a cash app notification")
    }
    func onNotificationReceived(push: LogDropPushPayload) {
        LogDropLogger.shared.logInfo("Cash app notification received")
    }
}
