//
//  AlertViewModel.swift
//  Plum
//
//  Created by adam.wienconek on 04.12.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

struct AlertViewModel {
    let title: String?
    let message: String?
    let actions: [UIAlertAction]
    let style: UIAlertController.Style
    
    init(title: String?, message: String?, actions: [UIAlertAction], style: UIAlertController.Style) {
        self.title = title
        self.message = message
        self.actions = actions
        self.style = style
    }
    
    
}
