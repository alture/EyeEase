//
//  LensFormViewModel.swift
//  EE Tracker
//
//  Created by Alisher Altore on 21.02.2024.
//

import Foundation
import Combine

final class LensFormViewModel: ObservableObject {
    
    // Input
    @Published var brandName: String = ""
    @Published var wearDuration: WearDuration = .monthly
    @Published var eyeSide: EyeSide = .both
    @Published var initialUseDate: Date = Date.now
    @Published var sphere: Sphere = Sphere()
    @Published var detail: LensDetail = LensDetail()
    @Published var isWearing: Bool = true
    
    // Output
    @Published var isNameValid = false
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    enum Status {
        case new
        case editable
        case changeable
        
        var actionTitle: String {
            switch self {
            case .new:
                return "Add"
            case .editable:
                return "Save"
            case .changeable:
                return "Change"
            }
        }
    }
    
    init(lensItem: LensItem?) {
        self.brandName = lensItem?.name ?? ""
        self.wearDuration = lensItem?.wearDuration ?? .biweekly
        self.eyeSide = lensItem?.eyeSide ?? .both
        self.initialUseDate = lensItem?.startDate ?? Date.now
        self.sphere = lensItem?.sphere ?? Sphere()
        self.detail = lensItem?.detail ?? LensDetail()
        self.isWearing = lensItem?.isWearing ?? true
        
        $brandName
            .receive(on: RunLoop.main)
            .map { name in
                return name.count > 0
            }
            .assign(to: \.isNameValid, on: self)
            .store(in: &cancellableSet)
    }
}
