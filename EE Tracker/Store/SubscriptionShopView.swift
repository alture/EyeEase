//
//  SubscriptionShopView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 12.03.2024.
//

import SwiftUI
import StoreKit

struct SubscriptionShopView: View {
    @Environment(\.passIDs.group) private var passGroupID
    var body: some View {
        SubscriptionStoreView(groupID: passGroupID) {
            SubscriptionShopContent()
        }
        .storeButton(.visible, for: .redeemCode)
    }
}

struct SubscriptionShopContent: View {
    var body: some View {
        VStack(spacing: 40.0) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
            VStack(spacing: 8.0) {
                Text("Eye Ease+")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                
                Text("Subscription to unlock all features, like push-notification, lens detail section and iCloud sync.")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

//struct SubscriptionShopRow: View {
//    
//    var body: some View {
//        
//    }
//}

//struct SubscriptionShopContent: View {
//    var body: some View {
//        VStack {
//            image
//            VStack(spacing: 3) {
//                title
//                desctiption
//            }
//        }
//        .padding(.vertical)
//        .padding(.top, 40)
//    }
//}
//​
//extension SubscriptionShopContent {
//    @ViewBuilder
//    var image: some View {
//        Image("movie")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 100)
//
//    }
//    @ViewBuilder
//    var title: some View {
//        Text("Flower Movie+")
//            .font(.largeTitle.bold())
//    }
//    @ViewBuilder
//    var desctiption: some View {
//        Text("Subscription to unlock all streaming videos, enjoy Blu-ray 4K quality, and watch offline.")
//            .fixedSize(horizontal: false, vertical: true)
//            .font(.title3.weight(.medium))
//            .padding([.bottom, .horizontal])
//            .foregroundStyle(.gray)
//            .multilineTextAlignment(.center)
//    }
//}

#Preview {
    SubscriptionShopView()
}
