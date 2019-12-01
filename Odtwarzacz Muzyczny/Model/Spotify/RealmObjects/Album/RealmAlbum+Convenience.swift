//
//  RealmAlbum+Convenience.swift
//  Plum
//
//  Created by Adam Wienconek on 20.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension RealmAlbum {
    
    static func factory(album: SavedAlbum) -> RealmAlbum {
        let rlm = RealmAlbum()
        
        rlm._source = album.album.source.rawValue
        rlm._albumName = album.album.albumName
        rlm._albumUid = album.album.albumUid
        rlm._albumArtistName = album.album.albumArtistName
        rlm._albumArtistUid = album.album.albumArtistUid
        rlm._releaseYear = album.album.releaseYear
        rlm._genre = album.album.genres?.first
        rlm._addedDate = ISO8601DateFormatter().date(from: album.addedAt ?? "")
        rlm._externalUrl = album.album.externalUrl?.absoluteString
        
        let imgs = ImageSize.allCases.compactMap { size -> String? in
            return album.album.artworkUrl(for: size)?.absoluteString
        }
        rlm.imagesURLs.append(objectsIn: imgs)
        return rlm
    }
    
    static func factory(track: SavedTrack) -> RealmAlbum {
        let rlm = RealmAlbum()
        
        rlm._source = track.track.source.rawValue
        rlm._albumUid = track.track.albumUid
        rlm._albumName = track.track.albumName
        rlm._albumArtistName = track.track.albumArtistName
        rlm._albumArtistUid = track.track.albumArtistUid
        rlm._genre = track.track.album.albumGenre
        rlm._releaseYear = track.track.album.releaseYear
        rlm._addedDate = ISO8601DateFormatter().date(from: track.addedAt ?? "")
        rlm._externalUrl = track.track.externalUrl?.absoluteString
        
        let imgs = ImageSize.allCases.compactMap { size -> String? in
            return track.track.artworkUrl(for: size)?.absoluteString
        }
        rlm.imagesURLs.append(objectsIn: imgs)
        return rlm
    }
}
