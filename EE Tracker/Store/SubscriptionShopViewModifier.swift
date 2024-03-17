//
//  SubscriptionShopViewModifier.swift
//  EE Tracker
//
//  Created by Alisher Altore on 17.03.2024.
//

import SwiftUI

struct SubscriptionShopViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .subscriptionPassStatusTask()
        .onAppear {
            PassManager.createSharedInstance()
        }
        .task {
            await PassManager.shared.observeTransactionUpdates()
            await PassManager.shared.checkForUnfinishedTransactions()
        }
    }
}

extension View {
    func subscriptionShop() -> some View {
        modifier(SubscriptionShopViewModifier())
    }
}
