//
//  CircleProgressView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI

struct CircleProgressView: View {
    @State var lensItem: LensItem
    var lineWidth: CGFloat = 4.0
    private var progressColor: Color {
        switch lensItem.progress {
        case 0.0...0.5:
            Color.green
        case 0.5...0.8:
            Color.orange
        default:
            Color.red
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray6), lineWidth: lineWidth)
            Circle()
                .trim(from: 0.0, to: lensItem.progress)
                .stroke(progressColor, lineWidth: lineWidth)
                .rotationEffect(.degrees(-90))
        }
        .background(.clear)
    }
}

#Preview {
    CircleProgressView(lensItem: LensItem(
        name: "",
        wearDuration: .monthly,
        startDate: Date(),
        totalNumber: 30,
        usedNumber: 10,
        resolvedColor: ColorComponents.fromColor(.red),
        diopter: -4.5)
    )
}
