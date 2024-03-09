//
//  LensTrackingTimelineView.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import SwiftUI

struct LensTrackingTimelineView: View {
    private(set) var wearDuration: Int
    private(set) var changeDate: Date
    @Binding var showingChangables: Bool
    
    func getConditionColor(for remainingDays: Int) -> Color {
        switch remainingDays {
        case 0...2: return Color.red
        case 3...6: return Color.yellow
        default:    return Color.green
        }
    }
    
    var body: some View {
        TimelineView(.everyMinute) { context in
            let remainingDays = getRemainingDays(for: context.date.startOfDay)
            let progressValue = getProgressValue(for: remainingDays)
            let hasExpired = remainingDays <= 0
            let readyToExpire = remainingDays <= 2
            let conditionColor = getConditionColor(for: remainingDays)
            
            VStack(alignment: .center, spacing: 20.0) {
                CircleProgressView(progressValue: progressValue, lineWidth: 10, progressColor: conditionColor)
                    .frame(width: 120, height: 120)
                    .overlay {
                        VStack(alignment: .center) {
                            Text("\(remainingDays)")
                                .font(.largeTitle)
                                .bold()
                            Text("\(remainingDays > 1 ? "days" : "day") left")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(Color(.systemGray2))
                        }
                    }
                
                VStack {
                    if hasExpired {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Expired on")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(changeDate.relativeFormattedDate())
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.red)
                        }
                    } else {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Change on")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(changeDate.relativeFormattedDate())
                                .foregroundStyle(conditionColor)
                                .font(.title2)
                                .bold()
                        }
                    }
                    
                    if readyToExpire || hasExpired {
                        Button(action: {
                            self.showingChangables.toggle()
                        }, label: {
                            Text("Change now")
                                .padding(4)
                                .fontWeight(.semibold)
                                .font(.title3)
                        })
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(Color.orange)
                    }
                    
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
        
        let remainingDays = max(0, daysInterval.day ?? 0)
        return remainingDays
    }
    
    private func getProgressValue(for remainingDays: Int) -> CGFloat {
        return CGFloat(
            1.0 - Double(remainingDays) / Double(wearDuration)
        )
    }
}

#Preview("Not expired") {
    LensTrackingTimelineView(
        wearDuration: SampleData.content[0].wearDuration.limit,
        changeDate: SampleData.content[0].changeDate,
        showingChangables: .constant(false)
    )
}

#Preview("Expired") {
    LensTrackingTimelineView(
        wearDuration: SampleData.content[0].wearDuration.limit,
        changeDate: Date.distantPast,
        showingChangables: .constant(false)
    )
}

#Preview("Ready to expire") {
    LensTrackingTimelineView(
        wearDuration: SampleData.content[2].wearDuration.limit,
        changeDate: SampleData.content[2].changeDate,
        showingChangables: .constant(false)
    )
}

