//
//  LensTrackingView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI
import SwiftData

struct LensTrackingView: View {
    @Environment(NavigationContext.self) private var navigationContext
    @Environment(\.passStatus) private var passStatus
    @State private var showingChangables: Bool = false
    @State private var readyToExpire: Bool = false
    
    private var sphereDesc: String {
        guard let lensItem = navigationContext.selectedLensItem else { return "" }
        guard let sphere = lensItem.sphere else { return "Not set" }
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
        if let lensItem = navigationContext.selectedLensItem {
            VStack {
                LensTrackingHeader(
                    name: lensItem.name,
                    initialDate: lensItem.startDate,
                    isWearing: lensItem.isWearing
                )
                
                LensTrackingTimelineView(
                    wearDuration: lensItem.wearDuration.limit,
                    changeDate: lensItem.changeDate,
                    showingChangables: self.$showingChangables
                ).padding(.top)
                
                LensInformationView(
                    wearDuration: lensItem.wearDuration.rawValue,
                    sphere: sphereDesc,
                    eyeSide: lensItem.eyeSide.rawValue
                ).padding(.top)
                
                if let detail = lensItem.detail, passStatus != .notSubscribed {
                    Image(systemName: "ellipsis")
                        .padding(8.0)
                        .font(.title2)
                        .foregroundStyle(Color(.systemGray4))
                    
                    LensDetailView(detail: detail)
                }
            }
            .sheet(isPresented: $showingChangables, content: {
                LensFormView(state: .changeable, lensItem: navigationContext.selectedLensItem)
            })
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            ContentUnavailableView(
                "No selected lens",
                systemImage: "eye.slash.circle.fill",
                description: Text("Select any lens on the top to show tracking information")
            )
            .padding(.top, 40)
        }
    }
}

struct LensTrackingHeader: View {
    var name: String
    var initialDate: Date
    var isWearing: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(name)")
                    .font(.title2)
                    .minimumScaleFactor(0.7)
                    .fontWeight(.bold)
                TimelineView(.everyMinute) { context in
                    Text(initialDate.relativeFormattedDate(with: "MMMM d, yyyy"))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

struct LensInformationView: View {
    var wearDuration: String
    var sphere: String
    var eyeSide: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            LensInformationRow(image: "hourglass.circle", title: "Type", value: wearDuration)
            LensInformationRow(image: "dial", title: "Power", value: sphere)
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

#Preview("Lens Default") {
    return LensTrackingView()
        .environment(NavigationContext())
}

#Preview("Lens Ready to expire") {
    return LensTrackingView()
        .environment(NavigationContext())
}

#Preview("Lens Expired") {
    return LensTrackingView()
        .environment(NavigationContext())
}
