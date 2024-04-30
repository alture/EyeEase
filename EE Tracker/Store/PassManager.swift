//
//  PassManager.swift
//  EE Tracker
//
//  Created by Alisher Altore on 12.03.2024.
//

import StoreKit

actor PassManager {
    private init() {}
    private(set) static var shared: PassManager!
    private var updatesTask: Task<Void, Never>?
    
    static func createSharedInstance() {
        shared = PassManager()
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

extension PassManager {
    func process(transaction verificationResult: VerificationResult<Transaction>) async {
        let transaction: Transaction
        switch verificationResult {
        case .verified(let t):
            transaction = t
        case .unverified:
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
        self.updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { break }
                
                await self.process(transaction: update)
            }
        }
    }
}
