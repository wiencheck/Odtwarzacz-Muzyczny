//
//  UIButton.swift
//  Musico
//
//  Created by Adam Wienconek on 07.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIButton {
    
    struct AssociatedKeys {
        static var tappedHandler: UInt8 = 0
        static var touchHandler: UInt8 = 0
    }
    
    var tappedHandler: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.tappedHandler) as? (() -> Void)
        } set {
            objc_setAssociatedObject(self, &AssociatedKeys.tappedHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        }
    }
    
    var touchHandler: ((UIControl.Event) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.touchHandler) as? ((UIControl.Event) -> Void)
        } set {
            objc_setAssociatedObject(self, &AssociatedKeys.touchHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(touchDown), for: .touchDown)
            addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        }
    }
    
    @objc private func touchDown() {
        touchHandler?(.touchDown)
    }
    
    @objc private func touchUp() {
        guard let touchHandler = touchHandler else {
            tappedHandler?()
            return
        }
        touchHandler(.touchUpInside)
    }
    
    var text: String? {
        get {
            return title(for: .normal)
        } set {
            setTitle(newValue, for: .normal)
        }
    }
    
    var textColor: UIColor? {
        get {
            return titleColor(for: .normal)
        } set {
            setTitleColor(newValue, for: .normal)
        }
    }
    
    @IBInspectable var imageContentMode: UIView.ContentMode {
        get {
            return imageView?.contentMode ?? .scaleToFill
        } set {
            imageView?.contentMode = newValue
        }
    }
    
    func setImageAnimated(_ image: UIImage?, for state: UIControl.State, duration: TimeInterval = 0.3, options: UIView.AnimationOptions = [.transitionCrossDissolve, .curveLinear], completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self, duration: duration, options: options, animations: {
            self.setImage(image, for: state)
        }, completion: completion)
    }
    
    func setBackgroundImageAnimated(_ image: UIImage?, for state: UIControl.State, duration: TimeInterval = 0.3, options: UIView.AnimationOptions = [.transitionCrossDissolve, .curveLinear], completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self, duration: duration, options: options, animations: {
            self.setBackgroundImage(image, for: .normal)
        }, completion: completion)
    }
    
    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
    
}
