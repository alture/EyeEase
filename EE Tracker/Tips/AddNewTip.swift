//
//  AddNewTip.swift
//  EE Tracker
//
//  Created by Alisher Altore on 18.03.2024.
//

import TipKit

struct AddNewTip: Tip {
    var options: [TipOption] {
        MaxDisplayCount(1)
    }
    
    var title: Text {
        Text("Add a new lens")
            .fontDesign(.rounded)
    }
    
    var message: Text? {
        Text("Start tracking your first lens!")
    }
}
