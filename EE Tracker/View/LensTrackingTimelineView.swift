//
//  LensTrackingTimelineView.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import SwiftUI

struct LensTrackingTimelineView: View {
    private(set) var wearDuration: WearDuration
    private(set) var changeDate: Date
    private(set) var lensHasExpired: Bool
    private(set) var remainingDays: Int
    private(set) var conditionColor: Color
    private(set) var progressValue: CGFloat
    
    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
            switch wearDuration {
            case .daily:
//                HStack(alignment: .firstTextBaseline) {
//                    VStack(alignment: .center, spacing: 4) {
//                        Button(action: {
//                            self.lensItem.decreaseQuantity(for: lensItem)
//                            UIImpactFeedbackGenerator().impactOccurred()
//                        }, label: {
//                            Image(systemName: "minus.circle")
//                                .font(.largeTitle)
//                        })
//                        .customDisabled(!(lensItem.usedNumber > 0))
//                        
//                        Text("Undo")
//                            .font(.headline)
//                            .foregroundStyle(.secondary)
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity)
//                    ZStack {
//                        VStack {
//                            Text("\(lensItem.usedNumber)")
//                                .font(.largeTitle)
//                                .bold()
//                            Text("Lens used")
//                                .font(.subheadline)
//                                .bold()
//                                .foregroundStyle(Color(.systemGray2))
//                        }
//                        CircleProgressView(lensItem: $lensItem, lineWidth: 10.0)
//                    }
//                    VStack(alignment: .center, spacing: 4) {
//                        Button(action: {
//                                self.lensItem.increaseQuantity(for: lensItem)
//                            UIImpactFeedbackGenerator().impactOccurred()
//                        }, label: {
//                            Image(systemName: "plus.circle")
//                                .font(.largeTitle)
//                        })
//                        .customDisabled(lensItem.usedNumber >= lensItem.totalNumber ?? 0)
//                        
//                        Text("Pick Up")
//                            .font(.headline)
//                            .foregroundStyle(.secondary)
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity)
//                }
                EmptyView()
            default:
                
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
            }
            
            if self.lensHasExpired {
                Text("Lens has expired")
                    .foregroundStyle(.red)
                    .font(.system(.title3, design: .default, weight: .bold))
                
            } else {
                switch wearDuration {
                case .daily:
//                    HStack {
//                        Text("You have")
//                        if let totalNumber = lensItem.totalNumber {
//                            Text("\(totalNumber - lensItem.usedNumber)")
//                                .foregroundStyle(lensItem.progressColor)
//                        }
//                        Text("lens in case")
//                    }
//                    .font(.system(.title3, design: .default, weight: .bold))
                    EmptyView()
                default:
                    HStack {
                        Text("Change on")
                        Text(changeDate, style: .date)
                            .foregroundStyle(conditionColor)
                    }
                    .font(.system(.title3, design: .default, weight: .bold))
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

}

#Preview {
    return LensTrackingTimelineView(
        wearDuration: .biweekly,
        changeDate: Calendar.current.date(byAdding: .day, value: 14, to: Date.now)!,
        lensHasExpired: false,
        remainingDays: 14,
        conditionColor: .green,
        progressValue: 0.0
    )
}
