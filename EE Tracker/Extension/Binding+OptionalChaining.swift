//
//  Binding+OptionalChaining.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.03.2024.
//

import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
  Binding(
    get: { lhs.wrappedValue ?? rhs },
    set: { lhs.wrappedValue = $0 }
  )
}
