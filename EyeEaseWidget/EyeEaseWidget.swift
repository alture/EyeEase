//
//  EyeEaseWidget.swift
//  EyeEaseWidget
//
//  Created by Alisher Altore on 02.04.2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct EyeEaseWidget: Widget {
    let kind: String = "Eye Ease Widget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: EyeEaseWidgetIntent.self,
            provider: EyeEaseTimelineProvider()) { entry in
                EyeEaseWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Tracking Overview")
        .description("Keep track of your current lens")
    }
}

#Preview(as: .systemMedium, widget: {
    EyeEaseWidget()
}, timeline: {
    EyeEaseWidgetEntry(date: .now, lensItem: SampleData.content[1])
})

#Preview(as: .systemSmall, widget: {
    EyeEaseWidget()
}, timeline: {
    EyeEaseWidgetEntry(date: .now, lensItem: SampleData.content[1])
})

