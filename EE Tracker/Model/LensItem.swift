//
//  LensItem.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import Foundation
import SwiftData

final class LensItem: Identifiable, Hashable, ObservableObject {
    static func == (lhs: LensItem, rhs: LensItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: UUID
    @Published var name: String
    @Published var specs: LensSpecs
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: UUID = UUID(), name: String = "", specs: LensSpecs) {
        self.id = id
        self.name = name
        self.specs = specs
    }
}
