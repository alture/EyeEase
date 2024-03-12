//
//  ProductSubscription.swift
//  EE Tracker
//
//  Created by Alisher Altore on 12.03.2024.
//

import OSLog
import StoreKit

actor ProductSubscription {
    private let logger = Logger(
        subsystem: "Meet SubscriptionView",
        category: "Product Subscription"
    )
    private init() {}
    private(set) static var shared: ProductSubscription!
    
    static func createSharedInstance() {
        shared = ProductSubscription()
    }
    
    func status(for statuses: [Product.SubscriptionInfo.Status], ids: PassIdentifiers) -> PassStatus {
           let effectiveStatus = statuses.max { lhs, rhs in
               let lhsStatus = PassStatus(
                   productID: lhs.transaction.unsafePayloadValue.productID,
                   ids: ids
               ) ?? .notSubscribed
               let rhsStatus = PassStatus(
                   productID: rhs.transaction.unsafePayloadValue.productID,
                   ids: ids
               ) ?? .notSubscribed
               return lhsStatus < rhsStatus
           }
        
           guard let effectiveStatus else {
               return .notSubscribed
           }
           
           let transaction: Transaction
           switch effectiveStatus.transaction {
           case .verified(let t):
               transaction = t
           case .unverified(_, let error):
               print("Error occured in status(for:ids:): \(error)")
               return .notSubscribed
           }
           
           if case .autoRenewable = transaction.productType {
               if !(transaction.revocationDate == nil && transaction.revocationReason == nil) {
                   return .notSubscribed
               }
               if let subscriptionExpirationDate = transaction.expirationDate {
                   if subscriptionExpirationDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                       return .notSubscribed
                   }
               }
           }
           return PassStatus(productID: transaction.productID, ids: ids) ?? .notSubscribed
       }
}

extension ProductSubscription {
    func process(transaction verificationResult: VerificationResult<Transaction>) async {
        do {
            let unsafeTransaction = verificationResult.unsafePayloadValue
            logger.log("""
            Processing transaction ID \(unsafeTransaction.id) for \
            \(unsafeTransaction.productID)
            """)
        }
        
        let transaction: Transaction
        switch verificationResult {
        case .verified(let t):
            logger.debug("""
            Transaction ID \(t.id) for \(t.productID) is verified
            """)
            transaction = t
        case .unverified(let t, let error):
            // Log failure and ignore unverified transactions
            logger.error("""
            Transaction ID \(t.id) for \(t.productID) is unverified: \(error)
            """)
            return
        }
        
        await transaction.finish()
    }
    
    func checkForUnfinishedTransactions() async {
        for await transaction in Transaction.unfinished {
            Task.detached(priority: .background) {
                await self.process(transaction: transaction)
            }
        }
    }
    
    func observeTransactionUpdates() async {
        for await update in Transaction.updates {
            await self.process(transaction: update)
        }
    }
}
