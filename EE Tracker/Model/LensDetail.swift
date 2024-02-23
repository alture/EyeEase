//
//  LensDetail.swift
//  EE Tracker
//
//  Created by Alisher Altore on 22.02.2024.
//

import Foundation

struct LensDetail: Codable {
    var baseCurve: String
    var dia: String
    var cylinder: String
    var axis: String
    
    var hasAnyValue: Bool {
        baseCurve != "" || dia != "" || cylinder != "" || axis != ""
    }
    
    init(baseCurve: String = "", dia: String = "", cylinder: String = "", axis: String = "") {
        self.baseCurve = baseCurve
        self.dia = dia
        self.cylinder = cylinder
        self.axis = axis
    }
}
