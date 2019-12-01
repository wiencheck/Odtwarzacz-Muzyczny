//
//  AWConcreteArtist.swift
//  Plum
//
//  Created by Adam Wienconek on 25.05.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

class AWConcreteArtist: AWArtist, AWConcreteMediaCollection {

    let albums: [AWAlbum]
    private(set)var items: [AWTrack]
    var image: AWImage?
    
    private(set)var source: AWMediaSource
    
    private(set)var albumArtistUid: String
    
    private(set)var albumArtistName: String
    
    private(set)var addedDate: Date?
    
    private(set)var externalUrl: URL?
    
    init(source: AWMediaSource, uid: String, name: String, addedDate: Date?, externalUrl: URL?, albums: [AWAlbum], items: [AWTrack], image: AWImage? = nil) {
        self.source = source
        self.albumArtistUid = uid
        self.albumArtistName = name
        self.addedDate = addedDate
        self.externalUrl = externalUrl
        
        self.albums = albums
        self.items = items
        self.image = image
    }
    
    convenience init(artist: AWArtist, albums: [AWAlbum], items: [AWTrack], image: AWImage? = nil) {
        self.init(source: artist.source, uid: artist.albumArtistUid, name: artist.albumArtistName, addedDate: artist.addedDate, externalUrl: artist.externalUrl, albums: albums, items: items, image: image)
    }
    
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        representativeItem.artwork(for: size, completion: completion)
    }
    
    func artworkUrl(for size: ImageSize) -> URL? {
        return representativeItem.artworkUrl(for: size)
    }
    
    func artwork(for size: ImageSize) -> UIImage? {
        return representativeItem.artwork(for: size)
    }
    
}
