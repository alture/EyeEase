//
//  LensSortOrder.swift
//  EE Tracker
//
//  Created by Alisher Altore on 28.01.2024.
//

import Foundation

enum LensSortOrder: String, Identifiable, CaseIterable {
    case olderToNew = "Old To New"
    case newToOlder = "New to Old"
    case brandName = "Brand Name"
    
    var id: Self {
        self
    }
}
