//
//  LensView.swift
//  EE Tracker
//
//  Created by Alisher on 06.12.2023.
//

import SwiftUI

struct LensView: View {
    @ObservedObject var lensItem: LensItem
    var draftLensItem: LensItem?
    @ObservedObject var viewModel: LenseViewModel
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
                    //                    self.draftLensItem = self.lensItem
                    LensCreateOrEditView(lensItem: lensItem)
                } else {
                    LensDetailView(lensItem: lensItem, viewModel: viewModel)
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
    LensView(lensItem: LensItem(
        name: "Preview Name",
        eyeSide: .paired,
        startDate: Date(),
        totalNumber: 0,
        currentNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 0),
             viewModel: LenseViewModel()
    )
}

extension EditMode {
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
