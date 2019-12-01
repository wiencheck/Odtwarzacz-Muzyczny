//
//  SimplifiedPlaylist.swift
//  Plum
//
//  Created by Adam Wienconek on 04/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension SimplifiedPlaylist {
    /// Returns id of playlist's creator.
    var userId: String? {
        // Playlist's uri should look like this
        // spotify:user:carltonrueb:playlist:6N21oyZp7N7v3JXU19J6vJ
        
        let components = uri.components(separatedBy: ":")
        guard components.count > 2 else {
            print("Playlist's uri was in incompatible format! \nMaybe API Changed?")
            return nil }
        return components[2]
    }
}
