//
//  AppDelegate.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 01/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var alertWindow: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        _ = AppContext.shared
        NetworkMonitor.shared.start()
        return true
    }


}

