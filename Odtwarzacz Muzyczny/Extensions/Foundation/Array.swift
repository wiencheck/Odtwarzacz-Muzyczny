//
//  Array.swift
//  Musico
//
//  Created by adam.wienconek on 17.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

extension Array {
    func at(_ index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    mutating func remove(at indexes: [Int]) {
        remove(at: IndexSet(indexes))
    }
    
    mutating func remove(at indexes: IndexSet) {
        for index in indexes.sorted(by: {$0 > $1}) {
            remove(at: index)
        }
    }
}
