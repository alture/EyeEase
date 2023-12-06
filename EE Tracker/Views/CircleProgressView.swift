//
//  CircleProgressView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI

struct CircleProgressView: View {
    var specs: LensSpecs
    var progress: CGFloat {
        switch specs.wearDuration {
        case .daily:
            return CGFloat(Double(specs.currentQuantity) / Double(specs.fullQuantity))
        default:
            return CGFloat(1.0 - Double(specs.remainingDays) / Double(specs.wearDuration.limit))
        }
    }
    private var progressColor: Color {
        switch CGFloat(progress) {
        case 0.0...0.5:
            Color.green
        case 0.5...0.8:
            Color.orange
        default:
            Color.red
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray6), lineWidth: 4.0)
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(progressColor, lineWidth: 4.0)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 30, height: 30)
            Text(
                specs.wearDuration == .daily 
                ? "\(specs.currentQuantity) left"
                : "\(specs.remainingDays) \(specs.remainingDays > 1 ? "days" : "day") left"
            )
            .font(.system(.subheadline, design: .rounded, weight: .bold))
            .foregroundStyle(Color(.systemGray2))
        }
    }
    
}

#Preview {
    CircleProgressView(specs: .default)
}
