//
//  LensTrackingTimelineView.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import SwiftUI

struct LensTrackingTimelineView: View {
    private(set) var name: String
    private(set) var wearDuration: Int
    private(set) var changeDate: Date
    @Binding var showingChangables: Bool
    
    func labelColor(for progress: Double) -> Color {
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
            return .red
        }
    }
    
    var body: some View {
        TimelineView(.everyMinute) { context in
            let remainingDays = getRemainingDays(for: context.date.startOfDay)
            let progressValue = getProgressValue(for: remainingDays)
            let currentDay = abs(wearDuration - remainingDays)
            let hasExpired = wearDuration - currentDay <= 0
            let readyToExpire = wearDuration - currentDay <= 2
            
            VStack(alignment: .center) {
                ZStack {
                    ProgressRingView(
                        progress: progressValue,
                        color: labelColor(for: progressValue)
                    )
                    
                    VStack(alignment: .center) {
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            Text(verbatim: "\(currentDay)")
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .foregroundStyle(labelColor(for: progressValue))
                            Text(verbatim: "/")
                                .font(.system(.title, design: .rounded, weight: .regular))
                                .foregroundStyle(.gray)
                            Text(verbatim: "\(wearDuration)")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(.gray)
                        }
                        Text(currentDay == 1 ? "used day" : "used days")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.vertical)
                
                Text(verbatim: "\(name)")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .padding(.bottom, 8.0)
                
                VStack(spacing: 4.0) {
                    Text(hasExpired ? "Expired" : "Next replacement")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.gray)
                    Text(verbatim: changeDate.relativeFormattedDate(with: "EEEE, MMMM d"))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(labelColor(for: progressValue))
                }
                
                if readyToExpire || hasExpired {
                    Button(action: {
                        self.showingChangables = true
                    }, label: {
                        Text("Replace now")
                            .padding(4)
                            .fontWeight(.semibold)
                            .font(.title3)
                    })
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(Color.orange)
                    .padding(.top, 4.0)
                }
                
            }
        }
    }
    
    private func getRemainingDays(for date: Date) -> Int {
        let calendar = Calendar.current
        let daysInterval = calendar.dateComponents(
            [.day],
            from: date,
            to: changeDate
        )
        
        let remainingDays = daysInterval.day ?? 0
        return remainingDays
    }
    
    private func getProgressValue(for remainingDays: Int) -> Double {
        return 1.0 - Double(remainingDays) / Double(wearDuration)
    }
}

//#Preview("Not expired") {
//    LensTrackingTimelineView(
//        wearDuration: SampleData.content[0].wearDuration.limit,
//        changeDate: SampleData.content[0].changeDate,
//        showingChangables: .constant(false)
//    )
//}
//
//#Preview("Expired") {
//    LensTrackingTimelineView(
//        wearDuration: SampleData.content[0].wearDuration.limit,
//        changeDate: Date.distantPast,
//        showingChangables: .constant(false)
//    )
//}
//
//#Preview("Ready to expire") {
//    LensTrackingTimelineView(
//        wearDuration: SampleData.content[2].wearDuration.limit,
//        changeDate: SampleData.content[2].changeDate,
//        showingChangables: .constant(false)
//    )
//}

#Preview(traits: .fixedLayout(width: 120, height: 120), body: {
    LensTrackingTimelineView(
        name: SampleData.content[0].name,
        wearDuration: SampleData.content[0].wearDuration.limit,
        changeDate: SampleData.content[0].changeDate,
        showingChangables: .constant(false)
    )
})
