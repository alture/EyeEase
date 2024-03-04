//
//  CircleProgressView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI

struct CircleProgressView: View {
    private(set) var progressValue: CGFloat
    private(set) var lineWidth: CGFloat = 4.0
    private(set) var progressColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
                .animation(.easeInOut, value: progressValue)
            Circle()
                .trim(from: 0.0, to: progressValue)
                .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progressValue)
        }
    }
}

#Preview {
    CircleProgressView(progressValue: 0.5, progressColor: .red)
}
