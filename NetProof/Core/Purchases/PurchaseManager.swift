import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published var isPremium = false
    let productIDs = ["netproof_premium_monthly", "netproof_premium_yearly", "netproof_lifetime", "netproof_single_report"]

    func refreshEntitlements() async {
        // TODO: verify transactions.
        isPremium = false
    }

    func purchase(productID: String) async throws {
        // TODO: implement real StoreKit purchase flow.
        if productID == "netproof_lifetime" { isPremium = true }
    }
}
