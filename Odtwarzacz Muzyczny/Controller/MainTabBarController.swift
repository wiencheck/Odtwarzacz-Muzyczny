//
//  MainTabBarController.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 03/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    private lazy var playerController: UIViewController = {
        let storyboard = UIStoryboard(name: "Player", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title == "Dummy" {
            present(playerController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    private func presentPlayerController() {
        
    }
}
