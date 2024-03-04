//
//  LensSortOrder.swift
//  EE Tracker
//
//  Created by Alisher Altore on 28.01.2024.
//

import Foundation

enum LensSortOrder: String, Identifiable, CaseIterable {
    case oldestFirst = "Olderst First"
    case newestFirst = "Newest Frist"
    case brandName = "Brand Name"
    
    var id: Self {
        self
    }
}
