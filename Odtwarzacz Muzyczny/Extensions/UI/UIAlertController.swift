//
//  UIAlertController.swift
//  Plum
//
//  Created by adam.wienconek on 11.12.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIAlertController {
    convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction]?) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        actions?.forEach({ self.addAction($0) })
    }
}
