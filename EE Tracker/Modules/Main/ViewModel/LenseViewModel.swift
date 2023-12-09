//
//  LenseViewModel.swift
//  EE Tracker
//
//  Created by Alisher on 08.12.2023.
//

import Foundation

final class LenseViewModel: ObservableObject {
    @Published var lenses: [LensItem] = []
    @Published var selectedLensItem: LensItem?
    
    @ObservationIgnored
    private let dataSourceModel: DataSourceModel
    
    func add(lens item: LensItem) {
        dataSourceModel.appendItem(item)
        lenses = dataSourceModel.fetchItems()
    }
    
    func remove(lens item: LensItem) {
        dataSourceModel.removeItem(item)
        lenses = dataSourceModel.fetchItems()
    }
    
    init(dataSourceModel: DataSourceModel = .shared) {
        self.dataSourceModel = dataSourceModel
        lenses = dataSourceModel.fetchItems()
    }
}
