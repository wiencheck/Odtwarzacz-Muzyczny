//
//  AWAlertController.swift
//  Plum
//
//  Created by Adam Wienconek on 16.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

class AWAlertController: UIAlertController {
    var tintColor: UIColor! = UIColor.blue
    
    private lazy var alertWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = DBClearViewController()
        window.backgroundColor = .clear
        window.windowLevel = UIWindow.Level.alert + 1
        return window
    }()
    
    /**
    Present the DBAlertController on top of the visible UIViewController.
    
    - parameter flag:       Pass true to animate the presentation; otherwise, pass false. The presentation is animated by default.
    - parameter completion: The closure to execute after the presentation finishes.
    */
    public func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let rootViewController = alertWindow.rootViewController {
            alertWindow.makeKeyAndVisible()
            
            rootViewController.present(self, animated: flag, completion: completion)
        }
    }
    
    class func configure(with model: AlertViewModel) -> AWAlertController {
        let alert = AWAlertController(title: model.title, message: model.message, preferredStyle: model.style)
        model.actions.forEach({ alert.addAction($0) })
        return alert
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.tintColor = tintColor
    }
}

// In the case of view controller-based status bar style, make sure we use the same style for our view controller
fileprivate class DBClearViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return UIApplication.shared.isStatusBarHidden
    }
    
}
