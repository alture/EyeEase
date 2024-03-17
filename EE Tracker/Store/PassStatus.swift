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
}

extension PassStatus: CustomStringConvertible {
    var description: String {
        switch self {
        case .notSubscribed:
            String(localized: "Not subscribed")
        case .monthly:
            String(localized: "Monthly")
        case .yearly:
            String(localized: "Yearly")
        }
    }
}

extension EnvironmentValues {
    private enum PassStatusEnvironmentKey: EnvironmentKey {
        static var defaultValue: PassStatus = .notSubscribed
    }
    
    private enum PassStatusLoadingEnvironmentKey: EnvironmentKey {
        static var defaultValue = true
    }
    
    fileprivate(set) var passStatus: PassStatus {
        get { self[PassStatusEnvironmentKey.self] }
        set { self[PassStatusEnvironmentKey.self] = newValue }
    }
    
    fileprivate(set) var passStatusIsLoading: Bool {
        get { self[PassStatusLoadingEnvironmentKey.self] }
        set { self[PassStatusLoadingEnvironmentKey.self] = newValue}
    }
}

private struct PassStatusTaskModifier: ViewModifier {
    @Environment(\.passIDs) private var passIDs
    
    @State private var state: EntitlementTaskState<PassStatus> = .loading
    
    private var isLoading: Bool {
        if case .loading = state { true } else { false }
    }
    
    func body(content: Content) -> some View {
        content
            .subscriptionStatusTask(for: passIDs.group) { state in
                guard let passManager = PassManager.shared else { fatalError("PassManager was nil.") }
                
                self.state = await state.map { @Sendable [passIDs] statuses in
                    await passManager.status(
                        for: statuses,
                        ids: passIDs
                    )
                }
                
                switch self.state {
                case .failure(let error):
                    print("Failed to check subscriptionm status: \(error)")
                case .success(let status):
                    print("Providing updated status: \(status)")
                case .loading: break
                @unknown default: break
                }
            }
            .environment(\.passStatus, state.value ?? .notSubscribed)
            .environment(\.passStatusIsLoading, isLoading)
    }
}

extension View {
    func subscriptionPassStatusTask() -> some View {
        modifier(PassStatusTaskModifier())
    }
}
