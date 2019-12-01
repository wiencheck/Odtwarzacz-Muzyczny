//
//  Date.swift
//  Plum
//
//  Created by Adam Wienconek on 06.03.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

extension Date {
    public static func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    public static func secondsBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: start, to: end).second!
    }
}
