//
//  ImageSize.swift
//  Plum
//
//  Created by Adam Wienconek on 08.03.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

enum ImageSize: Int, CaseIterable, CustomStringConvertible {
    case large = 0
    case medium = 1
    case small = 2
    
    var description: String {
        switch self {
        case .large:    return "large"
        case .medium:   return "medium"
        case .small:    return "small"
        }
    }
}

extension ImageSize {
    var cgSize: CGSize {
        switch self {
        case .large:
            return CGSize(width: 500, height: 500)
        case .medium:
            return CGSize(width: 300, height: 300)
        case .small:
            return CGSize(width: 120, height: 120)
        }
    }
    
    func isBiggerOrEqual(than size: ImageSize) -> Bool {
        return rawValue <= size.rawValue
    }
}

extension CGSize {
    static func size(for imageSize: ImageSize) -> CGSize {
        switch imageSize {
        case .large:
            return CGSize(width: 500, height: 500)
        case .medium:
            return CGSize(width: 350, height: 350)
        case .small:
            return CGSize(width: 200, height: 200)
        }
    }
}
