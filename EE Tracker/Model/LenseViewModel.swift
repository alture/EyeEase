//
//  LenseViewModel.swift
//  EE Tracker
//
//  Created by Alisher on 08.12.2023.
//

import Foundation

final class LenseViewModel: ObservableObject {
    @Published var lenses: [LensItem] = [
//        .init(name: "Lens Item 1", specs: .default),
//        .init(name: "Lens Item 2", specs: .default),
//        .init(name: "Lens Item 3", specs: .default),
//        .init(name: "Lens Item 4", specs: .default),
//        .init(name: "Lens Item 5", specs: .default)
    ]
    
    func add(new lens: LensItem) {
        lenses.append(lens)
    }
    
    func remove(lense item: LensItem) {
        guard let index = lenses.firstIndex(of: item) else { return }
        lenses.remove(at: index)
    }
}
