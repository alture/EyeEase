//
//  EyeEaseWidgetView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 03.04.2024.
//

import SwiftUI
import WidgetKit

struct TimelineOverview: View {
    var name: String
    var currentDay: Float
    var maxDays: Float
    var progress: CGFloat
    var body: some View {
        VStack {
            Gauge(
                value: currentDay,
                in: 0...maxDays,
                label: {
                    Text("Day(s)")
                },
                currentValueLabel: {
                    Text("\(Int(currentDay))")
                        .foregroundStyle(labelColor(for: progress))
                },
                minimumValueLabel: {
                    Text("0")
                        .foregroundStyle(Color.green)
                },
                maximumValueLabel: {
                    Text("\(Int(maxDays))")
                        .foregroundStyle(Color.red)
                }
            )
            .gaugeStyle(.accessoryCircular)
            .tint(Gradient(stops: [
                .init(color: .green, location: 0.0),
                .init(color: .green, location: 0.6),
                .init(color: .yellow, location: 0.8),
                .init(color: .orange, location: 0.9),
                .init(color: .red, location: 0.95)
            ]))
            Text(name)
                .lineLimit(2)
                .font(.headline)
                .minimumScaleFactor(0.7)
                .bold()
        }
    }
    
    func labelColor(for progress: CGFloat) -> Color {
        switch progress {
        case 0.0..<0.8:
            return .green
        case 0.8..<0.9:
            return .yellow
        case 0.9..<0.95:
            return .orange
        case 0.95...1:
            return .red
        default:
            return .green
        }
    }
}

struct ReplaceDateView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var date: Date
    var isExpired: Bool
    
    var body: some View {
        VStack {
            Text(isExpired ? "Expired" : "Next replacement")
                .font(.system(.caption, design: .rounded, weight: .regular))
                .foregroundStyle(Color.gray)
            
            Group {
                if widgetFamily == .systemSmall {
                    Text("\(date.relativeFormattedDate(with: "MMMM d"))")
                } else {
                    Text("\(date.relativeFormattedDate())")
                }
            }
            .font(.system(.subheadline, design: .rounded, weight: .bold))
        }
    }
}

struct WidgetDetailRow: View {
    var systemImage: String
    var title: String
    var content: String
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.gray)
                Text(content)
                    .font(.system(.subheadline, design: .rounded))
            }
        }
    }
}

struct EyeEaseWidgetEntryView : View {
    var entry: EyeEaseWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    
    private func getSphereDescription(by lensItem: LensItem) -> String {
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
        if let lensItem = entry.lensItem {
            HStack {
                VStack {
                    TimelineOverview(
                        name: lensItem.name,
                        currentDay: Float(currentDay),
                        maxDays: Float(lensItem.wearDuration.limit),
                        progress: getProgressValue()
                    )
                    
                    Spacer()
                    
                    ReplaceDateView(
                        date: lensItem.changeDate,
                        isExpired: remainingDays <= 0
                    )
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                
                
                if widgetFamily == .systemMedium {
                    VStack(alignment: .leading) {
                        WidgetDetailRow(systemImage: "hourglass.circle", title: "Wearing Type", content: "\(lensItem.wearDuration.rawValue)")
                        Spacer()
                        WidgetDetailRow(systemImage: "dial", title: "Eye Side", content: "\(lensItem.eyeSide.rawValue)")
                        Spacer()
                        WidgetDetailRow(systemImage: "eyes.inverse", title: "Power Range", content: "\(getSphereDescription(by: lensItem))")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
            .widgetURL(URL(string: "eyeease:///lensItemId=\(lensItem.id.uuidString)"))
            .containerBackground(.fill, for: .widget)
        } else {
            ContentUnavailableView("No tracking contact lens", systemImage: "clock.arrow.2.circlepath")
                .containerBackground(.fill, for: .widget)
        }
    }
    
    var currentDay: Int {
        guard let lensItem = entry.lensItem else { return 0 }
        return max(0, lensItem.wearDuration.limit - remainingDays)
    }
    
    var remainingDays: Int {
        return getRemainingDays()
    }
    
    private func getRemainingDays() -> Int {
        guard let lensItem = entry.lensItem else { return 0 }

        let calendar = Calendar.current
        let daysInterval = calendar.dateComponents(
            [.day],
            from: entry.date.startOfDay,
            to: lensItem.changeDate
        )
        
        let remainingDays = max(0, daysInterval.day ?? 0)
        return remainingDays
    }
    
    private func getProgressValue() -> CGFloat {
        guard let lensItem = entry.lensItem else { return 0.0 }

        return CGFloat(
            1.0 - Double(remainingDays) / Double(lensItem.wearDuration.limit)
        )
    }
}
