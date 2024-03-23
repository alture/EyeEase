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
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(lensItems) { item in
                        LensCarouselRow(name: item.name, isSelected: navigationContext.selectedLensItem?.id == item.id, isWearing: item.isWearing)
                            .id(item.id.uuidString)
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    navigationContext.selectedLensItem = item
                                    value.scrollTo(item.id.uuidString, anchor: .center)
                                }
                            }
                    }
                }
            }
            .onAppear {
                if let selectedLensItem = navigationContext.selectedLensItem {
                    value.scrollTo(selectedLensItem.id.uuidString, anchor: .center)
                } else {
                    navigationContext.selectedLensItem = lensItems.first
                }
            }
            .contentMargins(.horizontal, EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16), for: .scrollContent)
            .scrollIndicators(.hidden)
        }
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
