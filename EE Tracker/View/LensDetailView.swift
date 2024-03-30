//
//  LensDetailView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 20.01.2024.
//

import SwiftUI

struct LensDetailView: View {
    var detail: LensDetail
    var body: some View {
        HStack {
            LensDetailRow(title: "Bc", value: detail.baseCurve, predication: "mm")
            LensDetailRow(title: "Dia", value: detail.dia, predication: "mm")
            LensDetailRow(title: "Cyl", value: detail.cylinder, predication: "D")
            LensDetailRow(title: "Axis", value: detail.axis, predication: "°")
        }
    }
}

struct LensDetailRow: View {
    var title: String
    var value: String
    var predication: LocalizedStringKey
    var body: some View {
        VStack(alignment: .center, spacing: 4.0) {
            Text(title)
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 0) {
                if !value.isEmpty {
                    Text(value)
                    Text(predication)
                } else {
                    Text("—")
                        .foregroundStyle(Color(.systemGray4))
                }
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

#Preview {
    Group {
        LensDetailView(detail: SampleData.content[0].detail ?? LensDetail())
        LensDetailView(detail: SampleData.content[1].detail ?? LensDetail())
        LensDetailView(detail: SampleData.content[2].detail ?? LensDetail())
    }
}
