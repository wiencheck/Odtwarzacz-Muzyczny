//
//  AWConcreteAlbum.swift
//  Plum
//
//  Created by Adam Wienconek on 25.05.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

class AWConcreteAlbum: AWAlbum, AWConcreteMediaCollection {
    
    private(set)var items: [AWTrack]
    var image: AWImage?
    
    private(set)var source: AWMediaSource
    
    private(set)var albumName: String
    
    private(set)var albumUid: String
    
    private(set)var albumArtistUid: String
    
    private(set)var albumArtistName: String
    
    private(set)var releaseYear: String?
    
    private(set)var albumGenre: String?
    
    private(set)var addedDate: Date?
    
    private(set)var externalUrl: URL?
    
    init(source: AWMediaSource, name: String, uid: String, artistName: String, artistUid: String, releaseYear: String?, genre: String?, externalUrl: URL?, tracks: [AWTrack], image: AWImage? = nil) {
        self.source = source
        albumName = name
        albumUid = uid
        albumArtistUid = artistUid
        albumArtistName = artistName
        self.releaseYear = releaseYear
        self.albumGenre = genre
        self.externalUrl = externalUrl
        
        items = tracks
        self.image = image
    }
    
    convenience init(album: AWAlbum, tracks: [AWTrack], image: AWImage? = nil) {
        self.init(source: album.source, name: album.albumName, uid: album.albumUid, artistName: album.albumArtistName, artistUid: album.albumArtistUid, releaseYear: album.releaseYear, genre: album.albumGenre, externalUrl: album.externalUrl, tracks: tracks, image: image)
    }
    
    deinit {
        print(String(describing: self) + " deinit")
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
