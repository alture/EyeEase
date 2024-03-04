//
//  LensCarouselView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.01.2024.
//

import SwiftUI

struct LensCarouselView: View {
    @Binding private var lenses: [LensItem]
    @Binding private var selectedLensItem: LensItem?
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(lenses) { item in
                        LensCarouselRow(name: item.name, isSelected: selectedLensItem?.id == item.id, isOnLockScreen: item.isWearing)
                            .id(item.id.uuidString)
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    selectedLensItem = item
                                    value.scrollTo(item.id.uuidString, anchor: .center)
                                }
                            }
                    }
                }
            }
            .onAppear {
                if let selectedLensItem {
                    value.scrollTo(selectedLensItem.id.uuidString, anchor: .center)
                }
            }
            .contentMargins(.horizontal, EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16), for: .scrollContent)
            .scrollIndicators(.hidden)
        }
    }
    
    init(lenses: Binding<[LensItem]>, selectedLensItem: Binding<LensItem?>) {
        self._lenses = lenses
        self._selectedLensItem = selectedLensItem
    }
}

struct LensCarouselRow: View {
    var name: String
    var isSelected: Bool
    var isOnLockScreen: Bool
    var body: some View {
        HStack {
            if isOnLockScreen {
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
    LensCarouselView(lenses: .constant(SampleData.content), selectedLensItem: .constant(SampleData.content[0]))
}
