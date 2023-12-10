//
//  NewLensView.swift
//  EE Tracker
//
//  Created by Alisher on 08.12.2023.
//

import SwiftUI

struct NewLensView: View {
    @StateObject var draftLensItem: LensItem = LensItem(
        name: "",
        startDate: Date(),
        totalNumber: 0,
        usedNumber: 0,
        resolvedColor: ColorComponents.fromColor(.clear),
        diopter: 0
    )
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var body: some View {
        NavigationStack {
            LensCreateOrEditView(lensItem: self.draftLensItem)
                .navigationTitle("Create Lens")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            self.dismiss()
                        }
                    }
                    
                    if !self.draftLensItem.name.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                self.modelContext.insert(self.draftLensItem)
                                do {
                                    try self.modelContext.save()
                                } catch {
                                    fatalError(error.localizedDescription)
                                }
                                self.dismiss()
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    NewLensView()
        .modelContainer(previewContainer)
}
