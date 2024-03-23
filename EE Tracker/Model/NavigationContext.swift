//
//  NavigationContext.swift
//  EE Tracker
//
//  Created by Alisher Altore on 23.03.2024.
//

import SwiftUI

@Observable
final class NavigationContext {
    var selectedLensItem: LensItem?
    
    init(selectedLensItem: LensItem? = nil) {
        self.selectedLensItem = selectedLensItem
    }
}
