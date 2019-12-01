//
//  TimeInterval.swift
//  Musico
//
//  Created by adam.wienconek on 11.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

extension TimeInterval{
    func calculateFromTimeInterval() ->(minute: String, second: String){
        let minute_ = abs(Int((self/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(self.truncatingRemainder(dividingBy: 60)))
        
        let minute = minute_ > 9 ? "\(minute_)" : "\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    
    /// Returns time in minutes and seconds like this: 3:45
    var asString: String {
        let tuple = calculateFromTimeInterval()
        return "\(tuple.minute):\(tuple.second)"
    }
    
}
