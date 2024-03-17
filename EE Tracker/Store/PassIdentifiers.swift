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
            group: "D24CF096",
            montly: "pass.monthly",
            yearly: "pass.yearly"
        )
    }
    
    var passIDs: PassIdentifiers {
        get { self[PassIDsKey.self] }
        set { self[PassIDsKey.self] = newValue}
    }
}
