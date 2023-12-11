//
//  LensView.swift
//  EE Tracker
//
//  Created by Alisher on 06.12.2023.
//

import SwiftUI

struct LensView: View {
    @EnvironmentObject var lensItem: LensItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    
    private var isEditing: Bool {
        guard let editMode else { return false }
        return editMode.wrappedValue.isEditing
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isEditing {
                    LensCreateOrEditView()
                        .environmentObject(lensItem)
                    Button(role: .destructive, action: {
                        self.modelContext.delete(lensItem)
                        self.dismiss()
                    }, label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    })
                    .buttonStyle(.borderedProminent)
                    .padding()
                } else {
                    LensDetailView()
                        .environmentObject(lensItem)
                }
            }
            .navigationTitle(isEditing ? "Edit" : lensItem.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if self.isEditing {
                        Button("Cancel") {
                            self.editMode?.animation().wrappedValue.toggle()
                        }
                        .foregroundStyle(Color.teal)
                    } else {
                        Button("Close") {
                            self.dismiss()
                        }
                        .foregroundStyle(Color.teal)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.editMode?.animation().wrappedValue.toggle()
                    }, label: {
                        Text("\(isEditing ? "Save" : "Edit")")
                    })
                    .foregroundStyle(Color.teal)
                }
                
            }
        }
    }
}

#Preview {
    LensView()
        .environmentObject(LensItem(
            name: "Preview Name",
            wearDuration: .daily,
            startDate: Date(),
            totalNumber: 30,
            usedNumber: 10,
            resolvedColor: ColorComponents.fromColor(.red),
            diopter: -4.5,
            cylinder: nil,
            axis: nil))
        .modelContainer(previewContainer)
}

extension EditMode {
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
