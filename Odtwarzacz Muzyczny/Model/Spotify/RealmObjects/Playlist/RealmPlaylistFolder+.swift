//
//  RealmPlaylistFolder+.swift
//  Plum
//
//  Created by Adam Wienconek on 06/09/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift

extension RealmPlaylistFolder {
//    convenience init(name: String) {
//        self.init()
//
//        _playlistName = name
//        _playlistUid = UUID().uuidString
//        _source = AWMediaSource.spotify.rawValue
//    }
    
    convenience init(name: String, children: [RealmPlaylist] = []) {
        self.init()
        
        _playlistName = name
        _playlistUid = UUID().uuidString
        _source = AWMediaSource.spotify.rawValue
        
        children.forEach {
            self.insert(child: $0)
        }
    }
    
//    class func factory(name: String, children: [RealmPlaylist]) -> RealmPlaylistFolder {
//        let rlm = RealmPlaylistFolder(name: name)
//
//        children.forEach {
//            rlm.insert(child: $0)
//        }
//        return rlm
//    }
    
    func insert(child: RealmPlaylist) {
        let rlm = realm ?? Realm.create()
        
        try? rlm.write {
            child.parent = self
        }
    }
}
