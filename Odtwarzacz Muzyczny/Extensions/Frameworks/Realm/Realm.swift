//
//  Realm.swift
//  Plum
//
//  Created by Adam Wienconek on 11.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift

extension Realm {
    static func create() -> Realm {
        do {
            return try Realm()
        } catch let error {
            fatalError("*** Could not create Realm with error: \(error.localizedDescription) ***")
        }
    }
}
