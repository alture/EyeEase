//
//  SettingsViewModel.swift
//  EE Tracker
//
//  Created by Alisher on 04.12.2023.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var settingsModel: SettingsModel
    
    init(settingsModel: SettingsModel) {
        self.settingsModel = settingsModel
    }
}
