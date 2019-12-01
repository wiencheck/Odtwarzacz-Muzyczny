//
//  UIImageView.swift
//  Plum
//
//  Created by adam.wienconek on 27.12.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImageWithAnimation(_ image: UIImage?, options: UIView.AnimationOptions, duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self, duration: duration, options: options, animations: {
            self.image = image
        }, completion: completion)
    }
    
    func applyBlur(radius: Float, animated: Bool) {
        DispatchQueue.main.async {
            let blurredImage = self.image?.blurred(radius: radius)
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
                self.image = blurredImage
            })
        }
    }
}
