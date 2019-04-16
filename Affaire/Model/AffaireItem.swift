//
//  AffaireItem.swift
//  Affaire
//
//  Created by Gilles Poirot on 16/04/2019.
//  Copyright © 2019 iJiru. All rights reserved.
//

import Foundation

struct AffaireItem {
    var label = ""
    var checked = false
    
    init(with label: String) {
        self.label = label
    }
}
