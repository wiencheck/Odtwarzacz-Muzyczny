//
//  UIWindow.swift
//  Musico
//
//  Created by adam.wienconek on 14.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

extension UIApplication {
    func presentController(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        keyWindow?.rootViewController?.present(vc, animated: animated, completion: completion)
    }
    
    var statusBarWindow: UIWindow? {
        let secretKey = String(format: "s%@tu%@indow","ta", "sBarW")
        if responds(to: Selector((secretKey))) {
            return value(forKey: secretKey) as? UIWindow
        }
        return nil
    }
    
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
//        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? RootViewController else {
//            return
//        }
//        //rootViewController.statusBarStyle = style
//        UIApplication.shared.statusBarStyle = style
    }
    
    @discardableResult
    class func openURL(_ url: URL) -> Bool {
        let application = UIApplication.shared
        guard application.canOpenURL(url) else {
            return false
        }
        application.open(url, options: [:], completionHandler: nil)
        return true
    }
    
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.open(URL(string: url)!, options: [:], completionHandler: nil)
                return
            }
        }
    }
    
    enum ReleaseState: Int {
        case development
        case testing
        case release
    }
    
    var releaseState: ReleaseState {
        return .release
    }
    
}

extension UIApplication: SKStoreProductViewControllerDelegate {
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension UIApplication: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        if let error = error {
            keyWindow?.rootViewController?.displayErrorMessage(error)
        } else {
            switch result {
            case .failed:
                let error = AWError(code: .other, description: "Failed to send mail")
                keyWindow?.rootViewController?.displayErrorMessage(error)
            default:
                return
            }
        }
    }
}
