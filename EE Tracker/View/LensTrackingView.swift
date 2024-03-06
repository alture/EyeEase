//
//  LensTrackingView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI
import SwiftData

struct LensTrackingView: View {
    private(set) var lensItem: LensItem
    @Binding var showingChangables: Bool
    @State var readyToExpire: Bool = false
    
    private var sphereDesc: String {
        let sphere = lensItem.sphere
        switch lensItem.eyeSide {
        case .left:
            return "L: \(sphere.left)"
        case .right:
            return "R: \(sphere.left)"
        case .both:
            if sphere.isSame {
                return "\(sphere.left)"
            } else {
                return "\(sphere.left) | \(sphere.right)"
            }
        }
    }
    
    var body: some View {
        VStack {
            LensTrackingHeader(
                name: lensItem.name,
                initialDate: lensItem.startDate,
                isWearing: lensItem.isWearing
            )
            
            LensTrackingTimelineView(
                wearDuration: lensItem.wearDuration.limit,
                changeDate: lensItem.changeDate,
                readyToExpire: $readyToExpire
            ).padding(.top)
            
            LensInformationView(
                wearDuration: lensItem.wearDuration.rawValue,
                sphere: sphereDesc,
                eyeSide: lensItem.eyeSide.rawValue
            ).padding(.top)
            
            Image(systemName: "ellipsis")
                .padding(8.0)
                .font(.title2)
                .foregroundStyle(Color(.systemGray4))
            
            LensDetailView(detail: lensItem.detail)
            
            if readyToExpire {
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
    var initialDate: Date?
    var isWearing: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(name)")
                    .font(.title2)
                    .minimumScaleFactor(0.7)
                    .fontWeight(.bold)
                
                Group {
                    if
                        let initialDate,
                        isWearing {
                        Text("Started at: \(formattedDate(initialDate))")
                    } else {
                        Text("Not started")
                    }
                }
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
    var sphere: String
    var eyeSide: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            LensInformationRow(image: "hourglass.circle", title: "Period", value: wearDuration)
            LensInformationRow(image: "dial", title: "Sphere", value: sphere)
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

#Preview("Without change button") {
    return LensTrackingView(lensItem: SampleData.content[0], showingChangables: .constant(false))
}

#Preview("With change button") {
    return LensTrackingView(lensItem: SampleData.content[0], showingChangables: .constant(true))
}
