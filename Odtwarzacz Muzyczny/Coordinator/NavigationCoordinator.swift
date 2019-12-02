//
//  NavigationCoordinator.swift
//  Plum
//
//  Created by adam.wienconek on 07.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

protocol NavigationCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get set }
    init(context: AppContext)
}

extension NavigationCoordinator {
    init(context: AppContext) {
        fatalError("initializer not implemented")
    }
}
