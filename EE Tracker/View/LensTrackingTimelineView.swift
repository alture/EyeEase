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
    @Binding var readyToExpire: Bool
    
    func getConditionColor(for remainingDays: Int) -> Color {
        switch remainingDays {
            case 0...2: return Color.red
            case 3...6: return Color.yellow
            default:    return Color.green
        }
    }
    
    var body: some View {
        TimelineView(.everyMinute) { context in
            let remainingDays = getRemainingDays(for: Calendar.current.startOfDay(for: context.date))
            let progressValue = getProgressValue(for: remainingDays)
            let hasExpired = remainingDays <= 0
            let conditionColor = getConditionColor(for: remainingDays)
            let _ = print(context.date.description(with: .current))
            
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
                
                Group {
                    if hasExpired {
                        Text("Lens has expired")
                            .foregroundStyle(.red)
                            .font(.system(.title3, design: .default, weight: .bold))
                        
                    } else {
                        HStack {
                            Text("Change on")
                            Text(changeDate, style: .date)
                                .foregroundStyle(conditionColor)
                        }
                        .font(.system(.title3, design: .default, weight: .bold))
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
        if !readyToExpire, remainingDays <= 2 {
//            DispatchQueue.main.async {
//                self.readyToExpire.toggle()
//            }
        }
        
        return remainingDays
    }
    
    private func getProgressValue(for remainingDays: Int) -> CGFloat {
        return CGFloat(
            1.0 - Double(remainingDays) / Double(wearDuration)
        )
    }
}

#Preview {
    LensTrackingTimelineView(
        wearDuration: SampleData.content[0].wearDuration.limit,
        changeDate: SampleData.content[0].changeDate,
        readyToExpire: .constant(false)
    )
}
