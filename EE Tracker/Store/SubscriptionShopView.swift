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
        .tint(Color.teal)
    }
}

struct SubscriptionShopContent: View {
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(.top)
            
            VStack(spacing: 6.0) {
                Text("Eye Ease+")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                
                Text("Upgrate to plus for access all features.")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)

            }
            .padding(.bottom)
            
            ForEach(SubscriptionShopFeature.allCases) { feature in
                SubscriptionShopFeatureRow(feature: feature)
            }
            
            Spacer()
        }
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
            return "Lens Detail"
        case .moreThanOne:
            return "Multiple Lenses"
        }
    }
    
    var subtitle: String {
        switch self {
        case .reminder:
            return "Stay on track with timely reminders."
        case .detailSection:
            return "Add lens specifications such as Base Curve, Axis etc."
        case .moreThanOne:
            return "Manage and track multiple lenses ease."
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
}
