//
//  DispatchQueue.swift
//  Plum
//
//  Created by Adam Wienconek on 30.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static let spotlight = DispatchQueue(label: "spotlight",
                                         qos: .background)
    
    static let realm = DispatchQueue(label: "realm",
                                         qos: .background)
}
