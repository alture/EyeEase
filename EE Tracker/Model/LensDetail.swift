//
//  LensDetail.swift
//  EE Tracker
//
//  Created by Alisher Altore on 22.02.2024.
//

import Foundation
import SwiftData

@Model
final class LensDetail {
    var baseCurve: String = ""
    var dia: String = ""
    var cylinder: String = ""
    var axis: String = ""
    var lensItem: LensItem? = nil
    
    var hasAnyValue: Bool {
        baseCurve != "" || dia != "" || cylinder != "" || axis != ""
    }
    
    init(baseCurve: String = "", dia: String = "", cylinder: String = "", axis: String = "", lensItem: LensItem? = nil) {
        self.baseCurve = baseCurve
        self.dia = dia
        self.cylinder = cylinder
        self.axis = axis
        self.lensItem = lensItem
    }
}
