//
//  PassStatus.swift
//  EE Tracker
//
//  Created by Alisher Altore on 12.03.2024.
//

import StoreKit
import SwiftUI

enum PassStatus: Comparable, Hashable {
    case notSubscribed
    case monthly
    case yearly
    
    init?(productID: Product.ID, ids: PassIdentifiers) {
        switch productID {
        case ids.montly: self = .monthly
        case ids.yearly: self = .yearly
        default:         return nil
        }
    }
    
    var description: String {
        switch self {
        case .notSubscribed:
            "Upgrate to Pro"
        case .monthly:
            "Monthly"
        case .yearly:
            "Yearly"
        }
    }
}

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
