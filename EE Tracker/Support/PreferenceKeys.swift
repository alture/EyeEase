//
//  PreferenceKeys.swift
//  EE Tracker
//
//  Created by Alisher Altore on 13.03.2024.
//

import SwiftUI

struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
