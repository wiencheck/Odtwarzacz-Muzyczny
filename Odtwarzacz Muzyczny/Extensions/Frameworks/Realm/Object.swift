//
//  Object.swift
//  Plum
//
//  Created by Adam Wienconek on 05/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift

extension Object {
    var primaryKey: String? {
        guard let key = Self.primaryKey() else {
            return nil
        }
        return value(forKey: key) as? String
    }
}
