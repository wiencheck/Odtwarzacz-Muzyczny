//
//  UINavigationItem.swift
//  Plum
//
//  Created by Adam Wienconek on 21.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

extension UINavigationItem {
    func setBackButtonTitle(_ backTitle: String?, maxLenght: Int = 12) {
        if let backTitle = backTitle {
            let title = backTitle.count > maxLenght ? LocalizedStringKey.backButtonTitle.localized : backTitle
            backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        } else {
            backBarButtonItem?.title = nil
        }
    }
}
