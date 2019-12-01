//
//  UILabel.swift
//  Musico
//
//  Created by adam.wienconek on 11.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UILabel {

    public func setText(_ text: String?, options: UIView.AnimationOptions = [.transitionCrossDissolve, .curveLinear], animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        var shouldAnimate = animated
        if self.text == text {
            shouldAnimate = false
        }
        UIView.transition(with: self, duration: shouldAnimate ? 0.3 : 0, options: options, animations: {
            self.text = text
        }, completion: completion)
    }

}
