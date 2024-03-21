//
//  BrandNameTip.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.03.2024.
//

import TipKit

struct BrandNameTip: Tip {
    var title: Text {
        Text("Enter brand name")
            .fontDesign(.rounded)
    }
    
    var message: Text? {
        Text("Lorem ipsum")
    }
}
