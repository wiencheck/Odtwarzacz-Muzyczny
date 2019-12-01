//
//  UIViewController.swift
//  Musico
//
//  Created by adam.wienconek on 27.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var safeInsets: UIEdgeInsets {
        let preInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        guard let window = UIApplication.shared.keyWindow else { return preInsets }
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets
        } else {
            return preInsets
        }
    }
    
    var viewInsets: UIEdgeInsets {
        let preInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        guard let window = UIApplication.shared.keyWindow else { return preInsets }
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets
        } else {
            return UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        }
    }
    
    func displayErrorMessage(title: String? = nil, _ error: Error) {
        let alert = AWAlertController(title: title ?? "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func objc_dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func objc_dismiss() {
        dismiss(animated: false, completion: nil)
    }
    
}

extension UIViewController {
    func add(child controller: UIViewController, frame: CGRect, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        addChild(controller)
        controller.view.frame = frame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(controller.view)
        
        let duration: TimeInterval = animations == nil ? 0 : 0.2
        let a = animations ?? {}
        
        UIView.animate(withDuration: duration, animations: a) { finished in
            controller.didMove(toParent: self)
            completion?(finished)
        }
    }
    
    func remove(child controller: UIViewController, animated: Bool = true, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        
        controller.willMove(toParent: nil)
        let duration: TimeInterval = animated ? 0.2 : 0
        let a = animations ?? {
            controller.view.alpha = 0
        }
        
        UIView.animate(withDuration: duration, animations: a) { finished in
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            completion?(finished)
        }
    }
    
//    @objc var pageController: UIPageViewController? {
//        func f(responder: UIResponder?) -> UIPageViewController? {
//            if responder == nil { return nil }
//            if let page = responder as? UIPageViewController {
//                return page
//            } else {
//                return f(responder: responder?.next)
//            }
//        }
//        return f(responder: self)
//    }
}
