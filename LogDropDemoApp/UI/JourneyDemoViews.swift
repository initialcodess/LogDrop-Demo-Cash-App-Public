import SwiftUI
import WebKit
import LogDropSDK

struct CashPrimaryButton: View {
    let title: String
    var busy = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                if busy { ProgressView().tint(.white) } else { Text(title).fontWeight(.semibold) }
                Spacer()
            }
            .padding(.vertical, 16)
            .background(Color("PrimaryColor"))
            .foregroundColor(.white)
            .cornerRadius(12)
        }.disabled(busy)
    }
}

struct CashProfileView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var profile: CashProfile?
    @State private var tier = "standard"
    @State private var currency = "USD"
    @State private var busy = false
    @State private var error: String?
    @State private var saved = false
    @State private var resetMessage: String?
    @State private var uploadingLogs = false
    @State private var uploadMessage: String?
    @State private var uploadFailed = false
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill").font(.system(size: 44)).foregroundColor(Color("PrimaryColor"))
                        VStack(alignment: .leading) {
                            Text(profile?.username ?? "Your account").font(.headline)
                            Text("Make your account work for you").font(.caption).foregroundColor(.secondary)
                        }
                    }.padding(.vertical, 8)
                }
                Section("Account preferences") {
                    Picker("Account", selection: $tier) { Text("Standard").tag("standard"); Text("Premium").tag("premium") }
                    Picker("Preferred currency", selection: $currency) { ForEach(["USD", "EUR", "GBP"], id: \.self) { Text($0).tag($0) } }
                }
                Section {
                    Button { LogDrop.requestPushNotificationAuthorization() } label: {
                        Label("Enable notifications", systemImage: "bell.badge")
                    }
                    Text("Stay up to date with your payments and offers.").font(.caption).foregroundColor(.secondary)
                }
                Section {
                    CashPrimaryButton(title: saved ? "Preferences saved" : "Save preferences", busy: busy) { save() }
                        .disabled(profile == nil)
                    if let error { Text(error).foregroundColor(.red).font(.callout) }
                }
                Section("Demo tools") {
                    Button {
                        uploadingLogs = true
                        uploadMessage = nil
                        LogDropLogger.shared.logInfo("Manual log upload requested from demo tools")
                        LogDrop.sendLogs { result in
                            DispatchQueue.main.async {
                                uploadingLogs = false
                                switch result {
                                case .success(let uploaded):
                                    uploadFailed = !uploaded
                                    uploadMessage = uploaded ? "Logs uploaded successfully." : "Logs could not be uploaded. Try again."
                                case .failure(let error):
                                    uploadFailed = true
                                    uploadMessage = "Upload failed: \(error.localizedDescription)"
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Label(uploadingLogs ? "Uploading logs…" : "Upload logs", systemImage: "arrow.up.doc")
                            Spacer()
                            if uploadingLogs { ProgressView() }
                        }
                    }
                    .disabled(uploadingLogs)
                    if let uploadMessage {
                        Text(uploadMessage).font(.caption).foregroundColor(uploadFailed ? .red : .green)
                    }
                    Button("Reset offer applications") {
                        Task { @MainActor in
                            do {
                                let _: DemoSuccessResponse = try await APIClient.shared.request(url: URL(string: "\(Environment.API.baseURL)/demo/reset-applications")!, method: "POST", body: [String: String]())
                                resetMessage = "Offers are ready for another walkthrough."
                            } catch { resetMessage = error.localizedDescription }
                        }
                    }
                    if let resetMessage { Text(resetMessage).font(.caption).foregroundColor(.secondary) }
                    Button("Trigger profile crash", role: .destructive) {
                        LogDropLogger.shared.logInfo("User triggered the profile crash demonstration")
                        fatalError("unexpected nil value while loading profile")
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } } }
            .task { await load() }
            .onChange(of: tier) { _ in saved = false }
            .onChange(of: currency) { _ in saved = false }
        }.tint(Color("PrimaryColor"))
    }
    @MainActor private func load() async {
        do {
            let p: CashProfile = try await APIClient.shared.request(url: URL(string: "\(Environment.API.baseURL)/demo/profile")!)
            profile = p; tier = p.accountTier; currency = p.preferredCurrency
        } catch { self.error = error.localizedDescription }
    }
    private func save() {
        busy = true; error = nil
        Task { @MainActor in
            do {
                let p: CashProfile = try await APIClient.shared.request(url: URL(string: "\(Environment.API.baseURL)/demo/profile")!, method: "PUT", body: ProfileUpdate(accountTier: tier, preferredCurrency: currency))
                profile = p; p.syncAttributes(); saved = true
                LogDrop.trackCustomEvent(eventName: "preferences_updated", properties: ["account_tier": tier, "preferred_currency": currency])
            } catch { self.error = error.localizedDescription }
            busy = false
        }
    }
}

struct CashOffersView: View {
    @ObservedObject private var router = CashAppRouter.shared
    @State private var offers: [CashOffer] = []
    @State private var selected: CashOffer?
    @State private var error: String?
    @State private var loading = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("FOR YOUR EVERYDAY").font(.caption).foregroundColor(.secondary)
                        Text("A little more from your money").font(.system(size: 28, weight: .bold))
                        Text("Explore benefits designed around your account.").font(.subheadline).foregroundColor(.secondary)
                    }
                    if loading { ProgressView().frame(maxWidth: .infinity) }
                    if let error {
                        Text(error).foregroundColor(.red)
                        Button("Try again") { Task { await load() } }
                    }
                    ForEach(offers) { offer in
                        Button { selected = offer } label: {
                            CashOfferCard(offer: offer)
                        }.buttonStyle(.plain)
                    }
                }.padding(20)
            }.background(Color(.systemGray6)).navigationTitle("Offers")
            .task { await load() }
            .refreshable { await load() }
            .onChange(of: router.offerID) { id in openOffer(id) }
            .sheet(item: $selected, onDismiss: { Task { await load() } }) { CashOfferDetailView(offer: $0) }
        }.tint(Color("PrimaryColor"))
    }
    @MainActor private func load() async {
        loading = true; error = nil
        do { offers = try await APIClient.shared.request(url: URL(string: "\(Environment.API.baseURL)/demo/offers")!); openOffer(router.offerID) }
        catch { self.error = error.localizedDescription }
        loading = false
    }
    private func openOffer(_ id: String?) {
        guard let id, let offer = offers.first(where: { $0.id == id }) else { return }
        selected = offer; router.offerID = nil
    }
}

struct CashOfferCard: View {
    let offer: CashOffer
    private var statusLabel: String {
        if offer.status == "completed" { return offer.id == "premium" ? "REQUESTED" : "ACTIVATED" }
        return offer.status == "started" ? "IN PROGRESS" : "FOR YOU"
    }
    var body: some View {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: offer.icon).font(.title2).foregroundColor(Color("PrimaryColor"))
                                    Spacer()
                                    Text(statusLabel)
                                        .font(.caption2).fontWeight(.semibold).foregroundColor(Color("PrimaryColor"))
                                        .padding(8).background(Color("PrimaryColor").opacity(0.1)).cornerRadius(8)
                                }
                                Text(offer.subtitle).font(.title3).bold().foregroundColor(.primary)
                                Text(offer.benefit).font(.subheadline).foregroundColor(.secondary)
                                HStack { Text(offer.status == "started" ? "Continue application" : "View offer"); Spacer(); Image(systemName: "arrow.right") }
                                    .font(.subheadline.weight(.semibold)).foregroundColor(Color("PrimaryColor"))
                            }.padding(22).background(.white).cornerRadius(16).shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}

struct CashOfferDetailView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    let offer: CashOffer
    @State private var status = "available"
    @State private var busy = false
    @State private var error: String?
    @State private var accepted = false
    private var properties: [String: Any] { ["offer_id": offer.id, "offer_category": offer.category] }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 18).fill(LinearGradient(colors: [.black, Color("PrimaryColor")], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 180)
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: offer.icon).font(.largeTitle)
                            Text(offer.subtitle).font(.title2).bold()
                        }.foregroundColor(.white).padding(24)
                    }
                    Text(offer.title).font(.title2).bold()
                    Text(offer.detail).foregroundColor(.secondary)
                    if status == "completed" {
                        Label("You're all set", systemImage: "checkmark.circle.fill").font(.title3).foregroundColor(.green)
                        Text("Your request is saved. You can review other offers anytime.").foregroundColor(.secondary)
                        CashPrimaryButton(title: "Done") { dismiss() }
                    } else if status == "started" {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Review your request").font(.headline)
                            Label(offer.subtitle, systemImage: "checkmark.circle")
                            Label("Use your existing account", systemImage: "person.crop.circle")
                            Toggle("I have reviewed the offer details", isOn: $accepted)
                        }.padding().background(Color(.systemGray6)).cornerRadius(12)
                        CashPrimaryButton(title: offer.action, busy: busy) { update("completed") }.disabled(!accepted)
                        Button("Finish later") { dismiss() }.frame(maxWidth: .infinity)
                    } else {
                        CashPrimaryButton(title: "Get started", busy: busy) { update("started") }
                    }
                    if let error { Text(error).font(.callout).foregroundColor(.red) }
                }.padding(24)
            }
            .navigationTitle("Offer details").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() }.disabled(busy) } }
            .interactiveDismissDisabled(busy)
            .onAppear { status = offer.status; LogDrop.trackCustomEvent(eventName: "offer_viewed", properties: properties) }
        }.tint(Color("PrimaryColor"))
    }
    private func update(_ newStatus: String) {
        busy = true; error = nil
        Task { @MainActor in
            do {
                let result: ApplicationResponse = try await APIClient.shared.request(url: URL(string: "\(Environment.API.baseURL)/demo/offers/\(offer.id)/application")!, method: "POST", body: ApplicationUpdate(status: newStatus))
                let previous = status; status = result.status
                if status != previous {
                    LogDrop.trackCustomEvent(eventName: status == "started" ? "offer_application_started" : "offer_application_completed", properties: properties)
                }
            } catch { self.error = error.localizedDescription }
            busy = false
        }
    }
}

struct CashAddMoneyView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var amount = 100
    @State private var busy = false
    @State private var message: String?
    @State private var succeeded = false
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "plus.circle.fill").font(.system(size: 44)).foregroundColor(Color("PrimaryColor"))
                Text("Top up your wallet").font(.title).bold()
                Text("Choose an amount to add to your cash account.").foregroundColor(.secondary)
                Picker("Amount", selection: $amount) { ForEach([50, 100, 500], id: \.self) { Text("$\($0)").tag($0) } }.pickerStyle(.segmented).disabled(busy || succeeded)
                Text("Demo funds only. No card will be charged.").font(.caption).foregroundColor(.secondary)
                if let message { Text(message).foregroundColor(succeeded ? .green : .red) }
                Spacer()
                CashPrimaryButton(title: succeeded ? "Done" : "Add $\(amount)", busy: busy) {
                    if succeeded { dismiss() } else { add() }
                }
            }.padding(24).navigationTitle("Add money").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() }.disabled(busy) } }
                .interactiveDismissDisabled(busy)
        }
    }
    private func add() {
        busy = true; message = nil
        Task { @MainActor in
            do {
                let result: TopUpResponse = try await APIClient.shared.request(url: URL(string: "\(Environment.API.baseURL)/demo/add-money")!, method: "POST", body: TopUpRequest(amount: amount))
                succeeded = result.success; message = String(format: "Your balance is now $%.2f", result.balance)
                LogDrop.trackCustomEvent(eventName: "money_added", properties: ["amount": amount, "currency": "USD"])
            } catch { message = error.localizedDescription }
            busy = false
        }
    }
}

struct CashBillView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            CashBillWebView().navigationTitle("Pay a bill").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } } }
                .onAppear { LogDrop.trackCustomEvent(eventName: "bill_payment_started", properties: ["provider": "city_energy", "amount": 48.5, "currency": "USD"]) }
        }
    }
}
struct CashBillWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "cashBill")
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: URL(string: "\(Environment.API.baseURL)/demo/bills/page")!))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) { uiView.configuration.userContentController.removeScriptMessageHandler(forName: "cashBill") }
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        private var reported = false
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard !reported, let body = message.body as? [String: Any], body["event"] as? String == "bill_paid" else { return }
            reported = true
            LogDrop.trackCustomEvent(eventName: "bill_payment_completed", properties: ["provider": "city_energy", "amount": 48.5, "currency": "USD"])
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            LogDropLogger.shared.logError("Bill page failed to load: \(error.localizedDescription)")
        }
    }
}
