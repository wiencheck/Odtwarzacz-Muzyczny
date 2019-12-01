//
//  LikedState.swift
//  Plum
//
//  Created by Adam Wienconek on 18.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

enum LikedState: Int, CaseIterable {
    case none
    case disliked
    case liked
    
    /// Returned if the item doesn't support setting 'LikedState'
    case unavailable
}
