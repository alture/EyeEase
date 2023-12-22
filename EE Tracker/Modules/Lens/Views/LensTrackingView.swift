//
//  LensTrackingView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI

struct LensTrackingView: View {
    @EnvironmentObject var lensItem: LensItem
    @Environment(\.modelContext) private var modelContext
    @State private var isOptionalSectionShowing: Bool = false
    @State private var showingEdit: Bool = false
    @State private var showingConfirmation: Bool = false
    
    var body: some View {
        Section {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(lensItem.name)")
                            .font(.title2)
                            .minimumScaleFactor(0.7)
                            .fontWeight(.bold)
                        Text("Started at: \(formattedDate(lensItem.startDate))")
                            .font(.headline)
                            .foregroundStyle(.secondary)
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
                            .padding(4)
                    }
                    .foregroundStyle(.teal)
                }
                LensDetailHeaderView()
                    .environmentObject(lensItem)
                    .padding(.vertical, 16)
                HStack(alignment: .top, spacing: 8.0) {
                    LensDetailRow(image: "hourglass.circle", title: "Duration", value: lensItem.wearDuration.rawValue)
                    LensDetailRow(image: "dial", title: "Power", value: "\(lensItem.diopter ?? 0)")
                    LensDetailRow(image: "eyes.inverse", title: "Eye Side", value: lensItem.eyeSide.rawValue)
                }
            }
            
            
            

        } header: {
            HStack {
                Image(systemName: "pin")
                    .foregroundStyle(.teal)
                Text("Pinned Lens")
            }
        }
        .confirmationDialog("Delete Confirmation", isPresented: $showingConfirmation) {
            Button("Delete", role: .destructive) {
                
            }
            
            Button("Cancel", role: .cancel) {
                self.showingConfirmation.toggle()
            }
        } message: {
            Text("Are you sure to delete this Lens? After that is gonna be unpinned")
        }
        .sheet(isPresented: $showingEdit, content: {
            LensEditView()
                .environmentObject(lensItem)
        })
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct LensDetailRow: View {
    var image: String
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.secondary)
                .frame(width: 25, height: 25)
            
            Divider()
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
                .padding(.vertical)
            
            Divider()
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct DisabledButtonStyle: ButtonStyle {
    var disabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(disabled ? Color(.systemGray5) : Color.teal)
    }
}

struct DisabledModifier: ViewModifier {
    var disabled: Bool
    
    func body(content: Content) -> some View {
        content.buttonStyle(DisabledButtonStyle(disabled: disabled))
    }
}

extension Button {
    func customDisabled(_ disabled: Bool) -> some View {
        self.modifier(DisabledModifier(disabled: disabled))
            .disabled(disabled)
    }
}

#Preview {
    let lensItem = LensItem(
        name: "Preview Name",
        eyeSide: .paired,
        wearDuration: WearDuration.daily,
        startDate: Date(),
        totalNumber: 30,
        usedNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 5.0,
        cylinder: 5.0,
        axis: 10
    )
    return LensTrackingView()
        .environmentObject(lensItem)
}
