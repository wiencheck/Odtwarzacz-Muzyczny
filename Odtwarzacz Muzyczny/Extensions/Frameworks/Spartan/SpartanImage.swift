//
//  SpartanImage.swift
//  Plum
//
//  Created by Adam Wienconek on 26/08/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension Array where Element: SpartanImage {
    func url(for size: ImageSize) -> URL? {
        if let url = at(size.rawValue)?.url {
            return URL(string: url)
        } else {
            guard let url = first?.url else {
                return nil
            }
            return URL(string: url)
        }
    }
    
    func urlString(for size: ImageSize) -> String? {
        if let url = at(size.rawValue)?.url {
            return url
        } else {
            return first?.url
        }
    }
}
