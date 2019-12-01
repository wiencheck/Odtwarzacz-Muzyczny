//
//  UICollectionViewCell.swift
//  Plum
//
//  Created by Adam Wienconek on 28/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
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
