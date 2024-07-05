//
//  GetPlusButton.swift
//  EE Tracker
//
//  Created by Alisher Altore on 18.03.2024.
//

import SwiftUI

struct AvailableOnPlusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundStyle(.teal)
            .controlSize(.small)
    }
}

extension ButtonStyle where Self == AvailableOnPlusButtonStyle {
    static var availableOnPlus: Self { Self() }
}
