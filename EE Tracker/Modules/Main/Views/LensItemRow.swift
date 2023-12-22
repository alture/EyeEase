//
//  LenseItemRow.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI

struct LensItemRow: View {
    @EnvironmentObject var lensItem: LensItem
    @Environment(\.modelContext) private var modelContext
    @State private var showingEdit: Bool = false
    @State private var showingConfirmation: Bool = false
    private var isTracking: Bool {
        lensItem.isPinned
    }
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top, spacing: 8.0) {
                if lensItem.isPinned {
                    Image(systemName: "pin")
                        .foregroundStyle(.teal)
                }
                Spacer()
                
                Menu {
                    Button {
                        self.showingEdit.toggle()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        self.lensItem.isPinned.toggle()
                    } label: {
                        Label("\(self.lensItem.isPinned ? "Unpin" : "Pin")",
                              systemImage: "\(self.lensItem.isPinned ? "pin.slash" : "pin")")
                    }
                    .foregroundStyle(.teal)
                    
                    if lensItem.axis != nil || lensItem.cylinder != nil {
                        Menu {
                            if let cylinder = lensItem.cylinder {
                                Text("Cylinder: \(String(format: "%.1f", cylinder))")
                            }
                            
                            if let axis = lensItem.axis {
                                Text("Axis: \(String(format: "%.1f", axis))")
                            }
                        } label: {
                            Text("Show more")
                        }
                    }
                    
                    Divider()
                    
                    Button("Delete", role: .destructive) {
                        self.showingConfirmation.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundStyle(Color(.systemGray2))
                        .foregroundStyle(.teal)
                }
            }
            .padding(.bottom, 8)
            
            CircleProgressView(lineWidth: 5)
                .environmentObject(lensItem)
                .frame(width: 40, height: 40)
            Text(lensItem.limitDesciption)
                .font(.system(.subheadline, design: .default, weight: .bold))
                .foregroundStyle(Color(.systemGray2))
                .padding(.bottom, 8)
            
            Text(lensItem.name)
                .font(.body)
                .bold()

            Text("\(lensItem.wearDuration.rawValue) • \(String(format: "%.1f", lensItem.diopter ?? 0)) • \(lensItem.eyeSide.rawValue)")
                .font(.system(.subheadline, design: .default, weight: .medium))
                .foregroundStyle(Color(.systemGray2))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .confirmationDialog("Delete Confirmation", isPresented: $showingConfirmation) {
            Button("Delete", role: .destructive) {
                self.modelContext.delete(lensItem)
                self.showingConfirmation.toggle()
            }
            
            Button("Cancel", role: .cancel) {
                self.showingConfirmation.toggle()
            }
        } message: {
            Text("Are you sure to delete this Lens? After that is gonna be unpinned")
        }
        .sheet(isPresented: $showingEdit) {
            LensEditView()
                .environmentObject(lensItem)
        }
    }
}

#Preview {
    let lensItem = LensItem(
        name: "Preview Name",
        eyeSide: .paired,
        startDate: Date(),
        totalNumber: 0,
        usedNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 5,
        cylinder: 5,
        axis: 10)
    return LensItemRow()
        .environmentObject(lensItem)
}
