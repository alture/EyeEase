//
//  LensTrackingView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI
import SwiftData

struct LensTrackingView: View {
    @EnvironmentObject var lensItem: LensItem
    @State private var isOptionalSectionShowing: Bool = false
    @State private var showingConfirmation: Bool = false
    
    var removeAction: (() -> Void)
    
    var body: some View {
        VStack {
            LensTrackingHeader(
                showingConfirmation: $showingConfirmation,
                lensItem: lensItem
            )
            LensTrackingTimelineView()
                .environmentObject(lensItem)
                .padding(.top)
            LensInformationView(lensItem: lensItem)
                .padding(.top)
            
            Image(systemName: "ellipsis")
                .padding(8.0)
                .font(.title2)
                .foregroundStyle(Color(.systemGray4))
            
            LensDetailView(detail: lensItem.detail)
            
            if self.lensItem.usedPeriod == .readyToExpire {
                NavigationLink {
                    LensEditView()
                        .environment(lensItem)
                } label: {
                    Text("Replace with new one")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .foregroundStyle(.white)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                }
                .buttonStyle(.plain)
                .padding(.top)
                .padding(.bottom, 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .confirmationDialog("Delete Confirmation", isPresented: $showingConfirmation) {
            Button("Delete", role: .destructive) {
                removeAction()
            }
            
            Button("Cancel", role: .cancel) {
                self.showingConfirmation.toggle()
            }
        } message: {
            Text("Are you sure to delete this Lens?")
        }
    }
}

struct LensTrackingHeader: View {
    @Binding var showingConfirmation: Bool
    var lensItem: LensItem
    var body: some View {
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
                NavigationLink {
                    LensEditView()
                        .environmentObject(lensItem)
                } label: {
                    Label("Edit", systemImage: "pencil")
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
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct LensInformationView: View {
    var lensItem: LensItem
    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            LensInformationRow(image: "hourglass.circle", title: "Period", value: lensItem.wearDuration.rawValue)
            LensInformationRow(image: "dial", title: "Sphere", value: lensItem.sphereDescription)
            LensInformationRow(image: "eyes.inverse", title: "Eye Side", value: lensItem.eyeSide.rawValue)
        }
    }
}

struct LensInformationRow: View {
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
                .bold()
                .foregroundColor(.primary)
                .padding(.vertical, 6.0)
            
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
    return LensTrackingView(removeAction: {  })
        .environmentObject(SampleData.content[0])
}
