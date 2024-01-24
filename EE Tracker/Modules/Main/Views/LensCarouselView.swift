//
//  LensCarouselView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.01.2024.
//

import SwiftUI
import SwiftData

struct LensCarouselView: View {
    @Query(sort: \LensItem.startDate) private var lenses: [LensItem]
    @Binding var selectedLens: LensItem?
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(lenses) { item in
                        LensCarouselRow(item: item, isSelected: item == selectedLens)
                            .id(item.id.uuidString)
                            .onTapGesture {
                                withAnimation {
                                    selectedLens = item
                                    value.scrollTo(item.id.uuidString, anchor: .center)
                                }
                            }
                    }
                }
            }
            .onAppear {
                if selectedLens == nil {
                    selectedLens = lenses.first(where: { $0.isWearing }) ?? lenses.first
                }
                
                if let selectedLens {
                    value.scrollTo(selectedLens.id.uuidString, anchor: .center)
                }
            }
            .contentMargins(16, for: .scrollContent)
            .scrollIndicators(.hidden)
        }
    }
}

struct LensCarouselRow: View {
    var item: LensItem
    var isSelected: Bool
    var body: some View {
        HStack {
            if item.isWearing {
                Image(systemName: "eye.fill")
                    .foregroundStyle(isSelected ? .white : Color(.systemGray2))
            }
            Text("\(item.name)")
        }
        .foregroundStyle(isSelected ? .white : Color(.systemGray))
        .font(.headline)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        
        .background(isSelected ? .teal : .clear)
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
    LensCarouselView(selectedLens: .constant(nil))
        .modelContainer(previewContainer)
}
