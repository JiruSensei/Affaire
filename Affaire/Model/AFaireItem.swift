//
//  AFaireItem.swift
//  Affaire
//
//  Created by Gilles Poirot on 30/04/2019.
//  Copyright © 2019 iJiru. All rights reserved.
//

import Foundation
import RealmSwift

class AFaireItem : Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
