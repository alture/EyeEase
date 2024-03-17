//
//  RestorePurchasesButton.swift
//  EE Tracker
//
//  Created by Alisher Altore on 17.03.2024.
//

import SwiftUI
import StoreKit

struct RestorePurchasesButton: View {
    @State private var isRestoring = false
    
    var body: some View {
        Button {
            isRestoring = true
            Task.detached {
                defer { self.isRestoring = false}
                
                do {
                    try await AppStore.sync()
                } catch let error {
                    print("Can't restore purchases: \(error)")
                }
            }
        } label: {
            HStack {
                Image(systemName: "gobackward")
                Text("Restore Purchases")
            }
        }
        .foregroundStyle(Color.primary)
        .disabled(isRestoring)
    }
}

#Preview {
    RestorePurchasesButton()
}
