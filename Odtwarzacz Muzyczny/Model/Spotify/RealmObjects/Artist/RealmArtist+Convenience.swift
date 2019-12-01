//
//  RealmArtist+Convenience.swift
//  Plum
//
//  Created by Adam Wienconek on 20.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension RealmArtist {
    static func factory(album: SavedAlbum) -> RealmArtist {
        let rlm = RealmArtist()
        
        rlm._source = album.album.source.rawValue
        rlm._artistUid = album.album.albumArtistUid
        rlm._artistName = album.album.albumArtistName
        rlm._addedDate = ISO8601DateFormatter().date(from: album.addedAt ?? "")
        rlm._externalUrl = album.album.externalUrl?.absoluteString

        let imagesUrls = ImageSize.allCases.compactMap { size -> String? in
            return album.album.artworkUrl(for: size)?.absoluteString
        }
        rlm.imagesURLs.append(objectsIn: imagesUrls)
        return rlm
    }
    
    static func factory(track: SavedTrack) -> RealmArtist {
        let rlm = RealmArtist()
        
        rlm._source = track.track.source.rawValue
        rlm._artistName = track.track.albumArtistName
        rlm._artistUid = track.track.artistUid
        rlm._addedDate = ISO8601DateFormatter().date(from: track.addedAt ?? "")
        
        let imagesUrls = ImageSize.allCases.compactMap { size -> String? in
            return track.track.artworkUrl(for: size)?.absoluteString
        }
        rlm.imagesURLs.append(objectsIn: imagesUrls)
        return rlm
    }
}
