//
//  AWPlayer+.swift
//  Plum
//
//  Created by Adam Wienconek on 10/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

extension AWPlayer {
    
    public enum QueueIdentifier {
        case all
        case album(String)
        case artist(String)
        case playlist(String)
    }
}
