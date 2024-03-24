//
//  PassIdentifiers.swift
//  EE Tracker
//
//  Created by Alisher Altore on 17.03.2024.
//

import SwiftUI

struct PassIdentifiers {
    var group: String
    
    var montly: String
    var yearly: String
}

extension EnvironmentValues {
    private enum PassIDsKey: EnvironmentKey {
        static var defaultValue = PassIdentifiers(
            group: "21467879",
            montly: "com.alture.eyeease.pass.mothly",
            yearly: "com.alture.eyeease.pass.yearly"
        )
    }
    
    var passIDs: PassIdentifiers {
        get { self[PassIDsKey.self] }
        set { self[PassIDsKey.self] = newValue}
    }
}
