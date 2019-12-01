//
//  Track+AWTrack.swift
//  Plum
//
//  Created by adam.wienconek on 28.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension SimplifiedTrack: AWTrack {
    var source: AWMediaSource {
        return .spotify
    }
    
    var trackName: String {
        return name
    }
    
    var trackUid: String {
        return uid
    }
    
    var albumName: String {
        return album.albumName
    }
    
    var artistName: String {
        return artists.first!.name
    }
    
    var albumArtistName: String {
        if album.albumType == "compilation" && album.artists.first?.name.lowercased() == "various artists" {
            return LocalizedStringKey.variousArtists.localized
        } else {
            return artistName
        }
    }
    
    var playableUrl: String? {
        return uri
    }
    
    var duration: TimeInterval {
        return TimeInterval(durationMs / 1000)
    }
    
    func discNumber() -> Int? {
        guard discNumber > 0 else {
            return nil
        }
        return discNumber
    }
    
    func trackNumber() -> Int? {
        guard trackNumber > 0 else {
            return nil
        }
        return trackNumber
    }
    
    func artworkUrl(for size: ImageSize) -> URL? {
        return album.artworkUrl(for: size)
    }
    
    func artwork(for size: ImageSize) -> UIImage? {
        return nil
    }
    
    var addedDate: Date? {
        return nil
    }
    
    var externalUrl: URL? {
        guard let value = externalUrls["spotify"],
            let url = URL(string: value) else { return nil }
        return url
    }
    
//    func artwork(for size: ImageSize, completion: ((MPMediaItemArtwork?) -> Void)?) {
//        guard let artworkUrl = artworkUrl(for: size) else {
//            completion?(nil)
//            return
//        }
//        UIImage.getImage(from: artworkUrl) { image in
//            //TODO
//            //let artworkImage = image ?? AWAsset.no_artwork.image
//            guard let artworkImage = image else {
//                completion?(nil)
//                return
//            }
//            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 250, height: 250), requestHandler: { size in
//                return artworkImage
//            })
//            completion?(artwork)
//        }
//    }
    
//    func getLyrics(completion: @escaping (String?) -> Void) {
//        completion(nil)
//    }
    
    var albumUid: String {
        return album.uid
    }
    
    var artistUid: String {
        return artists.first!.uid
    }
    
    var albumArtistUid: String {
        if album.albumType == "compilation" && album.artists.first?.name.lowercased() == "various artists" {
            return .variousArtistsUid
        } else {
            return artists.first!.uid
        }
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
    
}
