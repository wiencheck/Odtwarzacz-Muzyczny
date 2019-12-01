//
//  RealmPlaylistTrack+.swift
//  Plum
//
//  Created by Adam Wienconek on 24/08/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension RealmPlaylistTrack {
//    class func factory(from track: Track) -> RealmPlaylistTrack {
//        let rlm = RealmPlaylistTrack()
//        
//        rlm._source = track.source.rawValue
//        rlm._playableUrl = track.playableUrl
//        rlm._duration = track.duration
//        rlm._trackNumber.value = track.trackNumber()
//        rlm._discNumber.value = track.discNumber()
//        
//        rlm._trackName = track.trackName
//        rlm._trackUid = track.trackUid
//        
//        rlm._albumName = track.albumName
//        rlm._albumUid = track.albumUid
//        
//        rlm._artistName = track.artistName
//        rlm._artistUid = track.artistUid
//        
//        rlm._albumArtistName = track.albumArtistName
//        rlm._albumArtistUid = track.albumArtistUid
//        rlm._externalUrl = track.externalUrl?.absoluteString
//        
//        let imagesUrls = ImageSize.allCases.compactMap { size -> String? in
//            return track.artworkUrl(for: size)?.absoluteString
//        }
//        rlm.imagesURLs.append(objectsIn: imagesUrls)
//                
//        return rlm
//    }
    
    class func factory(from track: AWTrack) -> RealmPlaylistTrack {
        let rlm = RealmPlaylistTrack()
        
        rlm._source = track.source.rawValue
        rlm._playableUrl = track.playableUrl
        rlm._duration = track.duration
        rlm._trackNumber.value = track.trackNumber()
        rlm._discNumber.value = track.discNumber()
        
        rlm._trackName = track.trackName
        rlm._trackUid = track.trackUid
        
        rlm._albumName = track.albumName
        rlm._albumUid = track.albumUid
        
        rlm._artistName = track.artistName
        rlm._artistUid = track.artistUid
        
        rlm._albumArtistName = track.albumArtistName
        rlm._albumArtistUid = track.albumArtistUid
        rlm._externalUrl = track.externalUrl?.absoluteString
        
        let imagesUrls = ImageSize.allCases.compactMap { size -> String? in
            return track.artworkUrl(for: size)?.absoluteString
        }
        rlm.imagesURLs.append(objectsIn: imagesUrls)
                
        return rlm
    }
}
