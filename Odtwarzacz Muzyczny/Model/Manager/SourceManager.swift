//
//  SourceManager.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 02/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import Foundation

protocol SourceManager {
    var onLoggedInStatusChange: ((Bool) -> Void)? { get set }
    var isLoggedIn: Bool { get }
    func logIn()
    func logOut()
}

extension SourceManager {
    func logOut() {
        print("'logOut' not implemented")
    }
}
