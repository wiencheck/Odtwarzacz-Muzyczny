//
//  AWNotificationManager.swift
//  Plum
//
//  Created by Adam Wienconek on 27.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit
import UserNotifications

class AWNotificationManager {
    
    enum NotificationType {
        /// Orange notification.
        case warning(AWMessage, (() -> Void)?)
        
        /// Red notification.
        case failure(AWMessage)
        /// Green notification.
        case success(AWMessage)
        
        /// Orange notification.
        case playNext(String)
        /// Purple notification
        case playLast(String)
        
        /// Blue notification.
        case info(AWMessage)
        
        /// Black notification.
        case log(String)
    }
    
//    class func post(notification: NotificationType) {
//        DispatchQueue.main.async {
//            let banner: MessageView
//            var config: SwiftMessages.Config
//
//            switch notification {
//            case .playNext(let title):
//                let message = "\"" + title + "\" " + LocalizedStringKey.willBePlayedNext.localized
//                (banner, config) = MessageView.configure(title: message, color: UIColor.CustomColors.accentOrange)
//
//            case .playLast(let title):
//                let message = "\"" + title + "\"" + LocalizedStringKey.willBePlayedLast.localized
//                (banner, config) = MessageView.configure(title: message, color: UIColor.CustomColors.accentPurple)
//
//            case .info(let message):
//                (banner, config) = MessageView.configure(with: message, color: UIColor.CustomColors.accentBlue)
//                config.duration = .seconds(seconds: 4)
//
//            case .warning(let message, let action):
//                (banner, config) = MessageView.configure(with: message, color: UIColor.CustomColors.accentOrange)
//                banner.tapHandler = { _ in
//                    action?()
//                }
//                config.duration = .seconds(seconds: 10)
//
//            case .failure(let message):
//                (banner, config) = MessageView.configure(with: message, color: UIColor.CustomColors.accentPinkRed)
//                config.duration = .seconds(seconds: 5)
//
//            case .success(let message):
//            (banner, config) = MessageView.configure(with: message, color: UIColor.CustomColors.spotifyGreen)
//
//            case .log(let message):
//                (banner, config) = MessageView.configure(title: message, color: .black)
//            }
//            SwiftMessages.show(config: config, view: banner)
//        }
//    }
    
    class func post(notification: NotificationType) {
        DispatchQueue.main.async {
//            let banner: BaseNotificationBanner
//            switch notification {
//            case .playNext(let title):
//                let message = "\"" + title + "\" " + LocalizedStringKey.willBePlayedNext.localized
//                banner = .configure(title: message, color: UIColor.CustomColors.accentOrange)
//                
//            case .playLast(let title):
//                let message = "\"" + title + "\"" + LocalizedStringKey.willBePlayedLast.localized
//                banner = .configure(title: message, color: UIColor.CustomColors.accentPurple)
//                
//            case .info(let message):
//                banner = .configure(with: message, color: UIColor.CustomColors.accentBlue)
//                
//            case .warning(let message, let action):
//                banner = .configure(with: message, color: UIColor.CustomColors.accentOrange)
//                banner.onTap = action
//                banner.duration = 10
//                
//            case .failure(let message):
//                banner = .configure(with: message, color: UIColor.CustomColors.accentPinkRed)
//                
//            case .success(let message):
//                banner = .configure(with: message, color: UIColor.CustomColors.accentGreen)
//                
//            case .log(let message):
//                banner = .configure(title: message, color: .black)
//            }
////            if let aw = UIApplication.shared.keyWindow?.rootViewController as? AWNavigationController {
////                aw.isStatusBarHidden = true
////            }
//            banner.show(queuePosition: .front)
        }
    }
    
    private static var loadingProcessesCount = 0
    
    class func beginLoading() {
        loadingProcessesCount += 1
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    class func endLoading(error: Error? = nil) {
        loadingProcessesCount -= 1
        DispatchQueue.main.async {
            if loadingProcessesCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = error {
                let message = AWMessage(with: error)
                let notification = NotificationType.failure(message)
                post(notification: notification)
            }
        }
    }
    
//    class func showLoadingBar() {
//        DispatchQueue.main.async {
//            GradientLoadingBar.shared = GradientLoadingBar(height: 4, isRelativeToSafeArea: false)
//            GradientLoadingBar.shared.gradientColors = [
//            Theme.tintColor.color,
//            Theme.backgroundColor
//            ]
//            GradientLoadingBar.shared.fadeIn()
//        }
//    }
//
//    class func hideLoadingBar() {
//        DispatchQueue.main.async {
//            GradientLoadingBar.shared.fadeOut()
//        }
//    }
    
}

//extension MessageView {
//    class func configure(title: String, subtitle: String? = nil, color: UIColor = UIColor.CustomColors.accentBlue, duration: TimeInterval = 2) -> (view: MessageView, config: SwiftMessages.Config) {
//
//        let view: MessageView
//
//        if let subtitle = subtitle {
//            view = MessageView.viewFromNib(layout: .messageView)
//            view.configureContent(title: title, body: subtitle)
//        } else {
//            view = MessageView.viewFromNib(layout: .statusLine)
//            view.configureContent(body: title)
//        }
//
//        view.titleLabel?.textColor = .white
//        view.bodyLabel?.textColor = .white
//        view.setFontWeight(.regular)
//        view.backgroundColor = color
//
//        var config = SwiftMessages.defaultConfig
//        config.duration = .seconds(seconds: duration)
//        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
//        config.preferredStatusBarStyle = .lightContent
//        return (view, config)
//    }
//
//    class func configure(with message: AWMessage, color: UIColor) -> (view: MessageView, config: SwiftMessages.Config) {
//        return configure(title: message.title, subtitle: message.message, color: color)
//    }
//
//    func setFontWeight(_ weight: UIFont.Weight) {
//        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: weight)
//        bodyLabel?.font = UIFont.systemFont(ofSize: 14, weight: weight)
//    }
//}
