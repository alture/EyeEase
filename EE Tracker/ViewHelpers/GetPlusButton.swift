//
//  GetPlusButton.swift
//  EE Tracker
//
//  Created by Alisher Altore on 18.03.2024.
//

import SwiftUI

struct GetPlusButton: View {
    @Binding var didTap: Bool
    
    var body: some View {
        Button("Get Plus to Set", systemImage: "crown.fill") {
            self.didTap.toggle()
        }
        .buttonStyle(.borderedProminent)
        .tint(.teal)
        .controlSize(.small)
    }
}

