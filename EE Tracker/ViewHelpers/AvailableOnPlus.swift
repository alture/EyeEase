//
//  AvailableOnPlus.swift
//  EE Tracker
//
//  Created by Alisher Altore on 18.03.2024.
//

import SwiftUI

fileprivate struct AvailableOnPlus: ViewModifier {
    @Environment(\.passStatus) private var passStatus
    func body(content: Content) -> some View {
        if passStatus == .notSubscribed {
            content
                .visualEffect { content, geometry in
                    return content.blur(radius: 2)
                }
                .disabled(true)

        } else {
            content
        }
    }
}

extension View {
    func availableOnPlus() -> some View {
        modifier(AvailableOnPlus())
    }
}
