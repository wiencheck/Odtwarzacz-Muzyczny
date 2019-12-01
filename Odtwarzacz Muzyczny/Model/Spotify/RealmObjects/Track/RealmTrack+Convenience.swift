//
//  RealmTrack+Convenience.swift
//  Plum
//
//  Created by Adam Wienconek on 20.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation
import Spartan

extension RealmTrack {

    static func factory(track: AWTrack) -> RealmTrack {
        let rlm = RealmTrack()
        
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
        
        rlm._addedDate = track.addedDate
        rlm._externalUrl = track.externalUrl?.absoluteString
        
        let imagesUrls = ImageSize.allCases.compactMap { size -> String? in
            return track.artworkUrl(for: size)?.absoluteString
        }
        rlm.imagesURLs.append(objectsIn: imagesUrls)
        
        return rlm
    }
    
    static func factory(track: SimplifiedTrack) -> RealmTrack {
        let rlm = RealmTrack()
        
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
        
        if let addedAt = track.addedAt {
            rlm._addedDate = ISO8601DateFormatter().date(from: addedAt)
        }
        
        let imagesUrls = ImageSize.allCases.compactMap { size -> String? in
            return track.artworkUrl(for: size)?.absoluteString
        }
        rlm.imagesURLs.append(objectsIn: imagesUrls)
        
        return rlm
    }
    
    static func factory(track: SavedTrack) -> RealmTrack {
        let rlm = factory(track: track.track)
        rlm._addedDate = ISO8601DateFormatter().date(from: track.addedAt)
        return rlm
    }
}
