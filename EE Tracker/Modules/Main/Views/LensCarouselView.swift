//
//  LensCarouselView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.01.2024.
//

import SwiftUI
import SwiftData

struct LensCarouselView: View {
    @Query private var lenses: [LensItem]
    private var didSelectItem: (LensItem) -> Void
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(lenses) { item in
                        LensCarouselRow(item: item)
                            .id(item.id.uuidString)
                            .onTapGesture {
                                withAnimation {
                                    didSelectItem(item)
                                    value.scrollTo(item.id.uuidString, anchor: .center)
                                }
                            }
                    }
                }
            }
            .onAppear {
                if let selectedLens = lenses.first(where: { $0.isSelected }) {
                    value.scrollTo(selectedLens.id.uuidString, anchor: .center)
                }
            }
            .contentMargins(.horizontal, EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16), for: .scrollContent)
            .scrollIndicators(.hidden)
        }
    }
    
    init(sortOrder: LensSortOrder, didSelectItem: @escaping (LensItem) -> Void) {
        let sortDescriptors: [SortDescriptor<LensItem>] = switch sortOrder {
        case .newToOlder:
            [SortDescriptor(\LensItem.startDate, order: .reverse)]
        case .olderToNew:
            [SortDescriptor(\LensItem.changeDate)]
        case .brandName:
            [SortDescriptor(\LensItem.name)]
        }
        
        _lenses = Query(sort: sortDescriptors, animation: .default)
        self.didSelectItem = didSelectItem
    }
    
//    private func didSelect(_ item: LensItem) {
//        lenses.forEach { $0.isSelected = item.id == $0.id }
//    }
}

struct LensCarouselRow: View {
    var item: LensItem
    var body: some View {
        HStack {
            if item.isWearing {
                Image(systemName: "eye.fill")
                    .foregroundStyle(item.isSelected ? .white : Color(.systemGray2))
            }
            Text("\(item.name)")
        }
        .foregroundStyle(item.isSelected ? .white : Color(.systemGray))
        .font(.headline)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        
        .background(item.isSelected ? .teal : .clear)
        .overlay(content: {
            if !item.isSelected {
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(.separator, lineWidth: 4.0)
            }
        })
        .cornerRadius(25.0)
    }
}

#Preview {
    LensCarouselView(sortOrder: .brandName, didSelectItem: { _ in })
        .modelContainer(previewContainer)
}
