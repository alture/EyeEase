//
//  CircleProgressView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI

struct CircleProgressView: View {
    @EnvironmentObject var lensItem: LensItem
    var lineWidth: CGFloat = 4.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
                .animation(.easeInOut, value: lensItem.progress)
            Circle()
                .trim(from: 0.0, to: lensItem.progress)
                .stroke(lensItem.progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: lensItem.progress)
        }
    }
}

#Preview {
    CircleProgressView()
        .environmentObject(SampleData.content[0])
}
