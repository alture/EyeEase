//
//  Bool+Comparable.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.01.2024.
//

import Foundation

extension Bool: Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        // the only true inequality is false < true
        lhs && !rhs
    }
}
