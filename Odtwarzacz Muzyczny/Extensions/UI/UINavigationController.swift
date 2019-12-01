//
//  UINavigationController.swift
//  Plum
//
//  Created by Adam Wienconek on 07.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

extension UINavigationController {
    func removeControllers(between start: UIViewController?, end: UIViewController?) {
        guard viewControllers.count > 1 else { return }
        let startIndex: Int
        if let start = start {
            guard let index = viewControllers.index(of: start) else {
                return
            }
            startIndex = index
        } else {
            startIndex = 0
        }
        
        let endIndex: Int
        if let end = end {
            guard let index = viewControllers.index(of: end) else {
                return
            }
            endIndex = index
        } else {
            endIndex = viewControllers.count - 1
        }
        let range = startIndex + 1 ..< endIndex
        viewControllers.removeSubrange(range)
    }
}
