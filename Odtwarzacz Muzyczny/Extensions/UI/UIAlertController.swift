//
//  UIAlertController.swift
//  Plum
//
//  Created by adam.wienconek on 11.12.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIAlertController {
    convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction]?) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        actions?.forEach({ self.addAction($0) })
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.alertWindow = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.alertWindow!.rootViewController = UIViewController()
        appDelegate.alertWindow!.windowLevel = .alert + 1
        appDelegate.alertWindow!.makeKeyAndVisible()
        appDelegate.alertWindow!.rootViewController?.present(self, animated: animated, completion: completion)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//         let appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
}
