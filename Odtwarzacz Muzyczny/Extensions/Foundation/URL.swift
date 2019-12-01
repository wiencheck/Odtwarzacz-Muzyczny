//
//  URL.swift
//  Plum
//
//  Created by Adam Wienconek on 30/08/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

extension URL {
    static func fromString(_ s: String?) -> URL? {
        guard let s = s, let url = URL(string: s) else {
            return nil
        }
        return url
    }
}
