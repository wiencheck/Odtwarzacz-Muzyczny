//
//  Coordinator.swift
//  Plum
//
//  Created by Adam Wienconek on 01/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

protocol Coordinator: class {
    var rootViewController: UINavigationController { get set }
    var context: AppContext { get set }
    func start()
}
