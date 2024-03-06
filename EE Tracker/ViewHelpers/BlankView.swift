//
//  BlankView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 06.03.2024.
//

import SwiftUI

struct BlankView : View {
    var bgColor: Color

    var body: some View {
        VStack {
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(bgColor)
        .edgesIgnoringSafeArea(.all)
    }
}
