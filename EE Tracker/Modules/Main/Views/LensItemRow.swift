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
            VStack(alignment: .leading, spacing: 8) {
//                HStack {
                    Text(lensItem.name)
                        .font(.system(.title2, design: .default, weight: .bold))
//                    Circle()
//                        .frame(width: 15, height: 15)
//                        .foregroundStyle(lensItem.color)
//                }
                Text("D: \(String(format: "%.1f", lensItem.diopter)) • \(lensItem.wearDuration.rawValue) • \(lensItem.eyeSide.rawValue)")
                    .font(.system(.body, design: .default, weight: .medium))
                    .foregroundStyle(Color(.systemGray2))
            }
            
            Spacer()
            VStack(alignment: .trailing) {
                CircleProgressView(lensItem: lensItem)
                    .frame(width: 30, height: 30)
                Text(lensItem.limitDesciption)
                .font(.system(.subheadline, design: .default, weight: .bold))
                .foregroundStyle(Color(.systemGray2))

            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

#Preview {
    LensItemRow(lensItem: LensItem(
        name: "Preview Name",
        eyeSide: .paired, 
        startDate: Date(),
        totalNumber: 0,
        usedNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 0)
    )
    .previewLayout(.fixed(width: 200, height: 50))
}
