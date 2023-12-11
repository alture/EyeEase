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
        VStack(alignment: .center) {
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
                        .customDisabled(lensItem.usedNumber >= lensItem.totalNumber)
                        
                        Text("Pick Up")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding(.bottom)
            default:
                ZStack {
                    VStack {
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
                .padding(.bottom)
            }
            
            switch lensItem.wearDuration {
            case .daily:
                HStack {
                    Text("You have")
                    Text("\(lensItem.totalNumber - lensItem.usedNumber)")
                        .foregroundStyle(.teal)
                    Text("lens in case")
                }
                .font(.system(.title3, design: .default, weight: .bold))
            default:
                HStack {
                    Text("Change on")
                    Text(lensItem.changeDate, style: .date)
                        .foregroundStyle(.teal)
                }
                .font(.system(.title3, design: .default, weight: .bold))
            }
        }
        .padding(.vertical)
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
