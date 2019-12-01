//
//  UIPageViewController.swift
//  Musico
//
//  Created by adam.wienconek on 08.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIPageViewController {
    var scrollView: UIScrollView? {
        return view.subviews.first(where: { view in
            view is UIScrollView
        }) as? UIScrollView
    }
}
