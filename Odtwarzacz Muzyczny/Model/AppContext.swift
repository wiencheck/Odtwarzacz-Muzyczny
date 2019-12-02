//
//  AppContext.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 02/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import Foundation

class AppContext {
    static let shared = AppContext()
    
    let player: AWPlayer
    let newRepo: NewRepo
    var managers: [SourceManager]
        
    private init() {
        player = AWPlayer()
        newRepo = NewRepo()
        managers = [iTunesManager()]
    }
}
