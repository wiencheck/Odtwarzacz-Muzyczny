//
//  UIWindow.swift
//  Musico
//
//  Created by adam.wienconek on 05.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIWindow {
    
    var safeInsets: UIEdgeInsets {
        let preInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        guard let window = UIApplication.shared.keyWindow else { return preInsets }
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets
        } else {
            return preInsets
        }
    }
}
