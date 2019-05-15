//
//  Category.swift
//  Affaire
//
//  Created by Gilles Poirot on 30/04/2019.
//  Copyright © 2019 iJiru. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name: String = ""
    let items = List<AFaireItem>()
    
}
