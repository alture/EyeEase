//
//  LensView.swift
//  EE Tracker
//
//  Created by Alisher on 06.12.2023.
//

import SwiftUI

struct LensView: View {
    @State var name: String
    @State var diopter: Float?
    @State var wearDuration: LensWearDuration
    @State var quantity: Int?
    @State var startDate: Date
    @State var color: Color
    @State var cylinder: Float?
    @State var axis: Int?
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    
                    HStack {
                        Text("Diopter")
                        Spacer()
                        TextField("-2.5", value: $diopter, format: .number)
                            .fixedSize()
                    }
                    
                    Picker("Wear duration", selection: $wearDuration) {
                        ForEach(LensWearDuration.allCases) { duration in
                            Text(duration.rawValue)
                        }
                    }
                    
                    if wearDuration == .daily {
                        withAnimation {
                            HStack {
                                Text("Quantity")
                                Spacer()
                                TextField("0", value: $quantity, format: .number)
                                    .fixedSize()
                            }
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    
                }
                
                Section(header: Text("Optional")) {
                    ColorPicker("Color", selection: $color)
                    
                    HStack {
                        Text("Cylinder")
                        Spacer()
                        TextField("5", value: $cylinder, format: .number)
                            .fixedSize()
                    }
                    
                    HStack {
                        Text("Axis")
                        Spacer()
                        TextField("5", value: $axis, format: .number)
                            .fixedSize()
                    }
                }
            }
            .navigationTitle("New lens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        self.dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add new") {
                        self.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LensView(
        name: "",
        diopter: nil,
        wearDuration: .daily,
        quantity: nil,
        startDate: Date(),
        color: .clear
    )
}
