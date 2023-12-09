//
//  LensDetailView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI

struct LensDetailView: View {
    var lensItem: LensItem
    @State var isOptionalSectionShowing: Bool = false
    
    var body: some View {
        List {
            Section {
                LensDetailRow(title: "Name", value: lensItem.name)
                LensDetailRow(title: "Power", value: "\(lensItem.specs.diopter)")
                LensDetailRow(title: "Eye Side", value: lensItem.specs.eyeSide.rawValue)
                LensDetailRow(title: "Wear Duration", value: lensItem.specs.wearDuration.rawValue)
                LensDetailRow(title: "Start Date", value: formattedDate(lensItem.specs.startDate))
            }
            
            Section(isExpanded: $isOptionalSectionShowing) {
                LensDetailRow(title: "Color", color: lensItem.specs.color)
                
                if let cylinder = lensItem.specs.cylinder {
                    LensDetailRow(title: "Cylinder", value: "\(cylinder)")
                }
                
                if let axis = lensItem.specs.axis {
                    LensDetailRow(title: "Axis", value: "\(axis)")
                }
            } header: {
                Text("Other Information")
            }
        }
        .listStyle(.sidebar)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct LensDetailRow: View {
    var title: String
    var value: String?
    var color: Color?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let value {
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            } else if let color {
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(color)
            }
        }
    }
}
#Preview {
    LensDetailView(lensItem: .init(name: "My Lens", specs: .default))
}
