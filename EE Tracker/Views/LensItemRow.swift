//
//  LenseItemRow.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI

struct LensItemRow: View {
    @ObservedObject var lensItem: LensItem
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(lensItem.name)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(lensItem.specs.color)
                }
                Text("D: \(String(format: "%.1f", lensItem.specs.diopter)) • \(lensItem.specs.wearDuration.rawValue) • \(lensItem.specs.eyeSide.rawValue)")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(Color(.systemGray2))
            }
            
            Spacer()
            CircleProgressView(specs: lensItem.specs)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    LensItemRow(lensItem: LensItem(name: "Preview Title", specs: .default)
    )
    .previewLayout(.fixed(width: 200, height: 50))
}
