//
//  UIScrollView.swift
//  Musico
//
//  Created by adam.wienconek on 16.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIScrollView {
    var isAtTop: Bool {
        return contentOffset == .zero
    }
    
    var isAtBottom: Bool {
        return contentOffset == bottomOffset
    }
    
    var bottomOffset: CGPoint {
        return CGPoint(x: 0, y: contentSize.height + contentInset.bottom - bounds.height)
    }
    
    func scrollToTop(animated: Bool) {
        setContentOffset(CGPoint.zero, animated: animated)
    }
}
