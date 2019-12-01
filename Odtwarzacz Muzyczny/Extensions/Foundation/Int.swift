//
//  Int.swift
//  Musico
//
//  Created by adam.wienconek on 05.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

extension Int {
    static func random(from: Int = 0, to: Int) -> Int {
        return Int(arc4random_uniform(UInt32(to - from))) + from
    }
    
    func ratingStars(maxRating: Int = 5) -> String {
        var r = ""
        for i in 0 ..< maxRating {
            if i < self {
                r += "★"
            } else {
                r += "☆"
            }
        }
        return r
    }
}
