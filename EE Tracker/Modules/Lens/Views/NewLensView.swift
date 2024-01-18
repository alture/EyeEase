//
//  NewLensView.swift
//  EE Tracker
//
//  Created by Alisher on 08.12.2023.
//

import SwiftUI

struct NewLensView: View {
    @State var draftLensItem: LensItem = LensItem(name: "", startDate: Date(), sphere: Sphere(), detail: LensDetail())
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var body: some View {
        NavigationStack {
            LensCreateOrEditView(lensItem: $draftLensItem)
                .navigationTitle("Create Lens")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            self.dismiss()
                        }
                        .foregroundStyle(.teal)
                    }
                    
                    if self.draftLensItem.isFilled {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                self.modelContext.insert(self.draftLensItem)
                                self.dismiss()
                            }
                            .foregroundStyle(.teal)
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
