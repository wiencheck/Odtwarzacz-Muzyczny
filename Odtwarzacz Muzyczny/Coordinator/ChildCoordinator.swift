//
//  ChildCoordinator.swift
//  Plum
//
//  Created by Adam Wienconek on 01/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

protocol ChildCoordinator: Coordinator {
    var navigationCoordinator: NavigationCoordinator? { get set }
}
