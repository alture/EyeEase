//
//  NewLensView.swift
//  EE Tracker
//
//  Created by Alisher on 08.12.2023.
//

import SwiftUI

struct NewLensView: View {
    @StateObject var draftLensItem: LensItem = LensItem(specs: .default)
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: LenseViewModel
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
                                self.viewModel.add(new: self.draftLensItem)
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
        .environmentObject(LenseViewModel())
}
