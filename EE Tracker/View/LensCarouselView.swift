//
//  LensCarouselView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.01.2024.
//

import SwiftUI
import SwiftData

struct LensCarouselView: View {
    @Environment(NavigationContext.self) private var navigationContext
    @Query(sort: \LensItem.createdDate) var lensItems: [LensItem]
    @State private var showingSubscriptionsSheet: Bool = false
    @Environment(\.passStatus) private var passStatus
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(lensItems) { item in
                        LensCarouselRow(name: item.name, isSelected: navigationContext.selectedLensItem?.id == item.id, isWearing: item.isWearing)
                            .id(item.id.uuidString)
                            .onTapGesture {
                                if disabledToSelect(item) {
                                    self.showingSubscriptionsSheet.toggle()
                                } else {
                                    withAnimation(.bouncy) {
                                        navigationContext.selectedLensItem = item
                                        value.scrollTo(item.id.uuidString, anchor: .center)
                                    }
                                }
                            }
                    }
                }
            }
            .sheet(isPresented: $showingSubscriptionsSheet, content: {
                SubscriptionShopView()
            })
            .onAppear {
                if let selectedLensItem = navigationContext.selectedLensItem {
                    value.scrollTo(selectedLensItem.id.uuidString, anchor: .center)
                } else {
                    navigationContext.selectedLensItem = lensItems.first
                }
            }
            .onOpenURL(perform: { url in
                guard let scheme = url.scheme else { return }
                
                let query = url.query ?? url.absoluteString.components(separatedBy: "\(scheme):///").last
                let queryItems = query?.components(separatedBy: "&").map { item -> (String, String) in
                    let keyValue = item.components(separatedBy: "=")
                    return (keyValue[0], keyValue.count > 1 ? keyValue[1] : "")
                }

                if let lensItemId = queryItems?.first(where: { $0.0 == "lensItemId" })?.1 {
                    navigationContext.selectedLensItem = lensItems.first(where: { $0.id.uuidString == lensItemId })
                }
            })
            .onNotification(perform: { notificationResponse in
                let notification = notificationResponse.notification
                let id = notification.request.identifier
                    .replacingOccurrences(of: "-day-before", with: "")
                    .replacingOccurrences(of: "-day-of", with: "")
                navigationContext.selectedLensItem = lensItems.first(where: { $0.id.uuidString == id })
            })
            .contentMargins(.horizontal, EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16), for: .scrollContent)
            .scrollIndicators(.hidden)
        }
    }
    
    func disabledToSelect(_ item: LensItem) -> Bool {
        guard let index = lensItems.firstIndex(of: item) else { return false }
        return passStatus == .notSubscribed && index > 0
    }
}

struct LensCarouselRow: View {
    var name: String
    var isSelected: Bool
    var isWearing: Bool
    var body: some View {
        HStack {
            if isWearing {
                Image(systemName: "eye.fill")
                    .foregroundStyle(isSelected ? .white : Color(.systemGray2))
            }
            Text("\(name)")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundStyle(isSelected ? .white : Color(.systemGray))
        .font(.headline)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        
        .background(isSelected ? .teal : Color(.systemBackground))
        .overlay(content: {
            if !isSelected {
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(.separator, lineWidth: 4.0)
            }
        })
        .cornerRadius(25.0)
    }
}

#Preview {
    LensCarouselView()
}
