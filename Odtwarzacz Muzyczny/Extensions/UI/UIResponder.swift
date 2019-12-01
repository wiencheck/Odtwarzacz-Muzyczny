//
//  UIResponder.swift
//  Plum
//
//  Created by Adam Wienconek on 16.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

extension UIResponder {
    func printResponderChain(starting responder: UIResponder?) {
        guard let responder = responder else { return }
        print(responder)
        printResponderChain(starting: responder.next)
    }
}
