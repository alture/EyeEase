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
        lensItem.isWearing
    }
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top, spacing: 8.0) {
                if lensItem.isWearing {
                    Image(systemName: "pin")
                }
                Spacer()
                
                Menu {
                    Button {
                        self.showingEdit.toggle()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        self.lensItem.isWearing.toggle()
                    } label: {
                        Label("\(self.lensItem.isWearing ? "Unpin" : "Pin")",
                              systemImage: "\(self.lensItem.isWearing ? "pin.slash" : "pin")")
                    }
                    .foregroundStyle(.teal)
                    
                    if lensItem.detail.hasAnyValue {
                        Menu {
                            let detail = lensItem.detail
                            
                            if !detail.baseCurve.isEmpty {
                                Text("Base Curve: \(detail.baseCurve)")
                            }
                            
                            if !detail.dia.isEmpty {
                                Text("Dia: \(detail.dia)")
                            }
                            
                            if !detail.cylinder.isEmpty {
                                Text("Cylinder: \(detail.cylinder)")
                            }
                            
                            if !detail.axis.isEmpty {
                                Text("Axis: \(detail.baseCurve)")
                            }
                            
                        } label: {
                            Text("Detail")
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

            Text("\(lensItem.wearDuration.rawValue) • \(String(format: "%.1f", lensItem.sphere.left)) • \(lensItem.eyeSide.rawValue)")
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
    return LensItemRow()
        .environmentObject(SampleData.content[0])
}
