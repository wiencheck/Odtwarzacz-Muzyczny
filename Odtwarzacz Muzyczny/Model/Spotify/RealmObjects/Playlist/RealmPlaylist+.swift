//
//  RealmPlaylist+.swift
//  Plum
//
//  Created by Adam Wienconek on 24/08/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension RealmPlaylist {
    class func factory(from playlist: SimplifiedPlaylist) -> RealmPlaylist {
        let rlm = RealmPlaylist()
        
        rlm._playlistUid = playlist.uid
        rlm._playlistName = playlist.name
        rlm._playlistDescription = playlist.playlistDescription
        rlm._source = playlist.source.rawValue
        rlm._user = playlist.userId
        rlm._attribute = playlist.attribute.rawValue
        rlm._trackCount = playlist.tracksObject.total
        rlm._externalUrl = playlist.externalUrl?.absoluteString
        
        let imgs = ImageSize.allCases.compactMap { size -> String? in
            return playlist.imageUrl(for: size)?.absoluteString
        }
        rlm.imagesURLs.append(objectsIn: imgs)
        
        return rlm
    }
}
