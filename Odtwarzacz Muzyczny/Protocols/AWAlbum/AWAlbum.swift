//
//  AWAlbum.swift
//  Plum
//
//  Created by adam.wienconek on 21.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import MediaPlayer

protocol AWAlbum {
    var source: AWMediaSource { get }
    
    var albumName: String { get }
    
    var albumUid: String { get }
    
    var sortAlbumName: String { get }
    
    var albumArtistUid: String { get }
    
    var albumArtistName: String { get }
    
    var sortAlbumArtistName: String { get }
    
    var releaseYear: String? { get }
    
    var albumGenre: String? { get }
    
    var addedDate: Date? { get }
    
    var externalUrl: URL? { get }
    
    /// Method which returns image for size given in parameter (size x size)
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void)
    
    func artworkUrl(for size: ImageSize) -> URL?
    
    func artwork(for size: ImageSize) -> UIImage?
    
    
}

extension AWAlbum {
    func equals(_ other: AWAlbum) -> Bool {
        return source == other.source && albumUid == other.albumUid
    }
    
    var sortAlbumName: String {
        return albumName.dropArticle()
    }
    
    var sortAlbumArtistName: String {
        return albumArtistName.dropArticle()
    }
}

