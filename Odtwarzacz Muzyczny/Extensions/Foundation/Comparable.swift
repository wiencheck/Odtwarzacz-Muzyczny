//
//  Comparable.swift
//  Plum
//
//  Created by Adam Wienconek on 31.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

extension Comparable where Self: Any {
    /**
     Returns value within range described by lower and upper bounds.
     For example, lower bound = 0, upper bound = 1.
     For value 0.8 the result will be 0.8
     For value 1.4 the result will be 1
     */
    func constrained(lowerBound: Self, upperBound: Self) -> Self {
        let _min = min(lowerBound, upperBound)
        let _max = max(lowerBound, upperBound)
        return max(_min, min(_max, self))
    }
}
