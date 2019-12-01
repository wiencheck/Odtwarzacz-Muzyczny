//
//  AWConcreteMediaCollection.swift
//  Plum
//
//  Created by Adam Wienconek on 04.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

protocol AWConcreteMediaCollection {
    var items: [AWTrack] { get }
    var representativeItem: AWTrack { get }
    var image: AWImage? { get set }
}

extension AWConcreteMediaCollection {
    var representativeItem: AWTrack {
        return items.first(where: { $0.artwork(for: .small) != nil }) ?? items.first!
    }
}
