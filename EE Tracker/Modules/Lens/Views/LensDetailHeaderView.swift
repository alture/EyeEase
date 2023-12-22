//
//  LensDetailHeaderView.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import SwiftUI

struct LensDetailHeaderView: View {
    @EnvironmentObject var lensItem: LensItem
    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
            switch lensItem.wearDuration {
            case .daily:
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .center, spacing: 4) {
                        Button(action: {
                            self.lensItem.decreaseQuantity(for: lensItem)
                            UIImpactFeedbackGenerator().impactOccurred()
                        }, label: {
                            Image(systemName: "minus.circle")
                                .font(.largeTitle)
                        })
                        .customDisabled(!(lensItem.usedNumber > 0))
                        
                        Text("Undo")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    ZStack {
                        VStack {
                            Text("\(lensItem.usedNumber)")
                                .font(.largeTitle)
                                .bold()
                            Text("Lens used")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(Color(.systemGray2))
                        }
                        CircleProgressView(lineWidth: 8.0)
                            .environmentObject(lensItem)
                    }
                    .frame(width: 130, height: 130)
                    VStack(alignment: .center, spacing: 4) {
                        Button(action: {
                                self.lensItem.increaseQuantity(for: lensItem)
                            UIImpactFeedbackGenerator().impactOccurred()
                        }, label: {
                            Image(systemName: "plus.circle")
                                .font(.largeTitle)
                        })
                        .customDisabled(lensItem.usedNumber >= lensItem.totalNumber ?? 0)
                        
                        Text("Pick Up")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            default:
                ZStack {
                    VStack(alignment: .center) {
                        Text("\(lensItem.remainingDays)")
                            .font(.largeTitle)
                            .bold()
                        Text("\(lensItem.remainingDays > 1 ? "days" : "day") left")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Color(.systemGray2))
                    }
                    CircleProgressView(lineWidth: 8.0)
                        .environmentObject(lensItem)
                    .frame(width: 130, height: 130)
                }
            }
            switch lensItem.wearDuration {
            case .daily:
                HStack {
                    if lensItem.usedNumber >= lensItem.totalNumber ?? 0 {
                        Text("Lens has expired")
                            .foregroundStyle(.red)
                            .font(.system(.title3, design: .default, weight: .bold))
                    } else {
                        Text("You have")
                        if let totalNumber = lensItem.totalNumber {
                            Text("\(totalNumber - lensItem.usedNumber)")
                                .foregroundStyle(lensItem.progressColor)
                        }
                        Text("lens in case")
                    }
                }
                .font(.system(.title3, design: .default, weight: .bold))
            default:
                HStack {
                    if lensItem.remainingDays <= 0 {
                        Text("Lens has expired")
                            .foregroundStyle(.red)
                    } else {
                        Text("Change on")
                        Text(lensItem.changeDate, style: .date)
                            .foregroundStyle(lensItem.progressColor)
                    }
                }
                .font(.system(.title3, design: .default, weight: .bold))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical, 8)
    }

}

#Preview {
    let lensItem = LensItem(
        name: "Preview Name",
        eyeSide: .paired,
        wearDuration: .daily,
        startDate: Date(),
        totalNumber: 30,
        usedNumber: 0,
        resolvedColor: ColorComponents.fromColor(.red),
        diopter: -4.5,
        cylinder: 8.0,
        axis: 2)
    return LensDetailHeaderView()
        .environmentObject(lensItem)
}
