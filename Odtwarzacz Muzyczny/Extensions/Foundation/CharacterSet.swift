//
//  CharacterSet.swift
//  PlumX
//
//  Created by adam.wienconek on 13.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

extension CharacterSet {
    
    static let english = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    static let numbers = CharacterSet(charactersIn: "0123456789")
    static let escapingCharacters = CharacterSet(charactersIn: "& ").inverted
    
}
