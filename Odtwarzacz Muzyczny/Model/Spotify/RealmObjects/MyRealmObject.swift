//
//  MyObject.swift
//  Plum
//
//  Created by Adam Wienconek on 05/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift
import Spartan

@objcMembers class MyRealmObject: Object {
    dynamic var shouldBeDeleted: Bool = false
    
    override var hash: Int {
        if let key = primaryKey {
            return key.hashValue
        }
        return super.hash
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let hashable = object as? AnyHashable {
            return hashValue == hashable.hashValue
        }
        return super.isEqual(object)
    }
}
