//
//  GlobalFunctions.swift
//  Plum
//
//  Created by Adam Wienconek on 31.05.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

// Given a value to round and a factor to round to,
// round the value to the nearest multiple of that factor.
func round(_ value: Double, toNearest: Double) -> Double {
    return round(value / toNearest) * toNearest
}

// Given a value to round and a factor to round to,
// round the value DOWN to the largest previous multiple
// of that factor.
func roundDown(_ value: Double, toNearest: Double) -> Double {
    return floor(value / toNearest) * toNearest
}

// Given a value to round and a factor to round to,
// round the value DOWN to the largest previous multiple
// of that factor.
func roundUp(_ value: Double, toNearest: Double) -> Double {
    return ceil(value / toNearest) * toNearest
}
