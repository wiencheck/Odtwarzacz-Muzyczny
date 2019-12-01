//
//  Refreshable.swift
//  Plum
//
//  Created by Adam Wienconek on 16.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

@objc protocol Refreshing {
    func handleRefreshSourcesEvent(_ sender: UIRefreshControl)
}

extension UIScrollView {
    func addRefreshSourcesControl() {
        refreshControl = {
            let r = UIRefreshControl()
            r.tintColor = .systemGray
            r.addTarget(nil, action: #selector(Refreshing.handleRefreshSourcesEvent(_:)), for: .valueChanged)
            return r
        }()
    }
}
