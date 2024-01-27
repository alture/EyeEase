//
//  LensEditView.swift
//  EE Tracker
//
//  Created by Alisher on 22.12.2023.
//

import SwiftUI

struct LensEditView: View {
    @State var draftLensItem: LensItem = LensItem(name: "Preview Name", startDate: Date(), sphere: Sphere(), detail: LensDetail())
    @EnvironmentObject var lensItem: LensItem
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationStack {
            LensCreateOrEditView(lensItem: draftLensItem)
                .navigationTitle(lensItem.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if draftLensItem.isFilled {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.save()
                                self.presentation.wrappedValue.dismiss()
                            }, label: {
                                Text("Save")
                            })
                            .foregroundStyle(Color.teal)
                        }
                    }
                }
                .onAppear {
                    self.fillDraftLenseItem()
                }
        }
    }
    
    private func fillDraftLenseItem() {
        draftLensItem = LensItem(
            name: lensItem.name,
            eyeSide: lensItem.eyeSide,
            wearDuration: lensItem.wearDuration,
            startDate: lensItem.startDate,
            totalNumber: lensItem.totalNumber,
            usedNumber: lensItem.usedNumber,
            sphere: lensItem.sphere,
            isWearing: lensItem.isWearing,
            detail: lensItem.detail
        )
    }
    
    private func save() {
        lensItem.name = draftLensItem.name
        lensItem.eyeSide = draftLensItem.eyeSide
        lensItem.wearDuration = draftLensItem.wearDuration
        lensItem.startDate = draftLensItem.startDate
        lensItem.totalNumber = draftLensItem.totalNumber
        lensItem.usedNumber = draftLensItem.usedNumber
        lensItem.sphere = draftLensItem.sphere
        lensItem.detail = draftLensItem.detail
        lensItem.isWearing = draftLensItem.isWearing
    }
}

#Preview {
    LensEditView()
        .environmentObject(SampleData.content[0])
}
