//
//  LensTrackingView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI
import SwiftData

struct LensTrackingView: View {
    @Binding var lensItem: LensItem
    @Binding var showingChangables: Bool
    
    var body: some View {
        VStack {
            LensTrackingHeader(name: lensItem.name, initialDate: lensItem.startDate)
            
            LensTrackingTimelineView(lensItem: $lensItem)
                .padding(.top)
            LensInformationView(
                wearDuration: lensItem.wearDuration.rawValue,
                sphereDesc: lensItem.sphereDescription,
                eyeSide: lensItem.eyeSide.rawValue
            )
                .padding(.top)
            
            Image(systemName: "ellipsis")
                .padding(8.0)
                .font(.title2)
                .foregroundStyle(Color(.systemGray4))
            
            LensDetailView(detail: lensItem.detail)
            
            if self.lensItem.usedPeriod == .readyToExpire {
                Button(action: {
                    self.showingChangables.toggle()
                }, label: {
                    Text("Replace with new one")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .foregroundStyle(.white)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                })
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
    var name: String
    var initialDate: Date
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(name)")
                    .font(.title2)
                    .minimumScaleFactor(0.7)
                    .fontWeight(.bold)
                Text("Started at: \(formattedDate(initialDate))")
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
    var wearDuration: String
    var sphereDesc: String
    var eyeSide: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            LensInformationRow(image: "hourglass.circle", title: "Period", value: wearDuration)
            LensInformationRow(image: "dial", title: "Sphere", value: sphereDesc)
            LensInformationRow(image: "eyes.inverse", title: "Eye Side", value: eyeSide)
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
    return LensTrackingView(lensItem: .constant(SampleData.content[0]), showingChangables: .constant(false))
}


//#Preview("With change button") {
//    return LensTrackingView(lensItem: .constant(SampleData.content[0]), showingChangables: .constant(true))
//}
