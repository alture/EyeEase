//
//  ContentView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 23.03.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationContext = NavigationContext()
    @AppStorage(AppStorageKeys.appAppearance) private var appAppearance: AppAppearance = .system

    var body: some View {
        LensDashboardView()
            .notificationGrantedTask()
            .preferredColorScheme(appAppearance == .system ? .none : (appAppearance == .dark ? .dark : .light ))
            .fontDesign(.rounded)
            .environment(navigationContext)
    }
}
