//
//  SubscriptionShopView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 12.03.2024.
//

import SwiftUI
import StoreKit

struct SubscriptionShopView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.passIDs.group) private var passGroupID
    @Environment(\.passStatus) private var passStatus
    
    var body: some View {
        SubscriptionStoreView(groupID: passGroupID) {
            SubscriptionShopContent()
        }
        .subscriptionStoreControlIcon(icon: { product, info in
            if info.groupLevel == 1 {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.teal)
            }
        })
        .onInAppPurchaseCompletion(perform: { (product: Product, result: Result<Product.PurchaseResult, Error>) in
            if case .success(.success(let transaction)) = result {
                await PassManager.shared.process(transaction: transaction)
                await NotificationManager.shared.reloadLocalNotificationByItems(true)
                
                dismiss()
            }
        })
        .storeButton(.visible, for: .redeemCode)
        .tint(Color.teal)
    }
}

struct SubscriptionShopContent: View {
    @Environment(\.passStatus) private var passStatus

    var body: some View {
        VStack {
            Image(systemName: "crown.fill")
                .foregroundStyle(Color.teal)
                .font(.largeTitle)
                .padding(.top)
                .padding(.bottom, 2.0)
            
            VStack(spacing: 6.0) {
                Text("Eye Ease+")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                
                Group {
                    if passStatus == .notSubscribed {
                        Text("Upgrate to plus for access all features.")
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(passStatus.description)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .overlay(.gray, in: .capsule.stroke())
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.gray)

            }
            .padding(.bottom, 20)
            
            ForEach(SubscriptionShopFeature.allCases) { feature in
                SubscriptionShopFeatureRow(feature: feature)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

enum SubscriptionShopFeature: CaseIterable, Identifiable {
    case reminder
    case detailSection
    case moreThanOne
    
    var title: String {
        switch self {
        case .reminder:
            return "Push Notifications"
        case .detailSection:
            return "Detail of the contact lens"
        case .moreThanOne:
            return "More than one contact lens"
        }
    }
    
    var subtitle: String {
        switch self {
        case .reminder:
            return "Stay on track with timely reminders."
        case .detailSection:
            return "Add contact lens specifications such as Power Range, Base Curve, Axis etc."
        case .moreThanOne:
            return "Manage and track multiple contact lenses"
        }
    }
    
    var icon: Image {
        switch self {
        case .reminder:
            return Image(systemName: "bell.square.fill")
                .symbolRenderingMode(.palette)
        case .detailSection:
            return Image(systemName: "slider.horizontal.2.square")
                .symbolRenderingMode(.palette)
        case .moreThanOne:
            return Image(systemName: "plus.square.fill.on.square.fill")
                .symbolRenderingMode(.palette)
        }
    }
    
    var accentColor: (Color, Color) {
        switch self {
        case .reminder:
            return (.white, .orange)
        case .detailSection:
            return (.green, .green)
        case .moreThanOne:
            return (.white, .blue)
        }
    }
    
    var id: Self {
        return self
    }
}

struct SubscriptionShopFeatureRow: View {
    let feature: SubscriptionShopFeature
    
    var body: some View {
        HStack(alignment: .top, spacing: 16.0) {
            feature.icon
                .resizable()
                .scaledToFit()
                .foregroundStyle(feature.accentColor.0, feature.accentColor.1)
                .frame(width: 25, height: 25)
            
            VStack(alignment: .leading, spacing: 4.0) {
                Text(feature.title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Text(feature.subtitle)
                    .font(.system(.subheadline))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.bottom, 8.0)
    }
}

#Preview {
    SubscriptionShopView()
        .environment(\.passStatus, .notSubscribed)
}
