//
//  UITableViewCell.swift
//  Plum
//
//  Created by Adam Wienconek on 28.12.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func removeSectionSeparators() {
        for subview in subviews {
            if subview != contentView && subview.frame.width == frame.width {
                subview.removeFromSuperview()
            }
        }
    }
    
    func mask(fromTop margin: CGFloat) {
        layer.mask = visibilityMask(withLocation: margin / frame.size.height)
        layer.masksToBounds = true
    }
    
    private func visibilityMask(withLocation location: CGFloat) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = bounds
        mask.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        let num = location as NSNumber
        mask.locations = [num, num]
        return mask
    }
}

protocol CellSeparatable {
    var separatorView: UIView? { get }
}

extension CellSeparatable {
    func setSeparatorColor(_ c: UIColor?) {
        separatorView?.backgroundColor = c
    }
}
