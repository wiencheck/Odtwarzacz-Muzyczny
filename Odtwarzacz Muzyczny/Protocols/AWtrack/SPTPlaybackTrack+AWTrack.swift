//
//  SPTPlaybackTrack+AWTrack.swift
//  Plum
//
//  Created by Adam Wienconek on 11.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

extension SPTPlaybackTrack: AWTrack {
    var source: AWMediaSource {
        return .spotify
    }
    
    var trackName: String {
        return name
    }
    
    var trackUid: String {
        return uri
    }
    
    var playableUrl: String? {
        return uri
    }
    
    func discNumber() -> Int? {
        return nil
    }
    
    func trackNumber() -> Int? {
        return nil
    }
    
    var albumArtistName: String {
        return artistName
    }
    
    func artworkUrl(for size: ImageSize) -> URL? {
        guard let coverArtUrl = albumCoverArtURL else { return nil }
        return URL(string: coverArtUrl)
    }
    
    func artwork(for size: ImageSize) -> UIImage? {
        return nil
    }
    
    var albumUid: String {
        return albumUri
    }
    
    var artistUid: String {
        return artistUri
    }
    
    var albumArtistUid: String {
        return artistUri
    }
    
    var userRating: Int {
        get {
            return 0
        } set {
            print("*** You can't set rating on SimplifiedTrack you idiot ***")
        }
    }
    
    var available: Bool {
        return true
    }
    
    var addedDate: Date? {
        return nil
    }
    
    var externalUrl: URL? {
        let s = "https://open.spotify.com/track/" + uri
        return URL(string: s)
    }
    
}
