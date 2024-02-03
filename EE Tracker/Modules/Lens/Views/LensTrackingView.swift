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
    
    var body: some View {
        VStack {
            LensTrackingHeader(
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
                    LensCreateOrEditView(lensItem: lensItem, status: .change)
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
    }
}

struct LensTrackingHeader: View {
    var lensItem: LensItem
    var body: some View {
        HStack {
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
    return LensTrackingView()
        .environmentObject(SampleData.content[0])
}
