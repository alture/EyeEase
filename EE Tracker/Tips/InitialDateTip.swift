//
//  InitialDateTip.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.03.2024.
//

import TipKit

struct InitialDateTip: Tip {
    @Parameter
    static var brandNameEntered: Bool = false
    
    var options: [TipOption] {
        MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        #Rule(Self.$brandNameEntered) {
            $0 == true
        }
    }
    
    var title: Text {
        Text("Choose the date of first wear")
    }
    
    var message: Text? {
        Text("By default, today's date is selected")
    }
}
