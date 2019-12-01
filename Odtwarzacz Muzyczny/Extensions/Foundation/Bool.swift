//
//  Bool.swift
//  Musico
//
//  Created by adam.wienconek on 19.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

extension Bool {
    mutating func reverse() {
        self = !self
    }
    
    var reversed: Bool {
        return !self
    }
}
