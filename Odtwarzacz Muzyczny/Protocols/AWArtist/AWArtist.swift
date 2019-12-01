//
//  AWArtist.swift
//  Plum
//
//  Created by adam.wienconek on 21.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

protocol AWArtist {
    var source: AWMediaSource { get }
    
    /// Unique artist's identifier.
    var albumArtistUid: String { get }
    
    /// Artist's name.
    var albumArtistName: String { get }
    
    /// Artist's name without prefix.
    /// For example, for 'The White Stripes' this will return 'White Stripes'.
    var sortAlbumArtistName: String { get }
        
    /// Returns artists image downloaded from web.
    func getImage(for size: ImageSize, completion: @escaping (UIImage?) -> Void)
    
    /// Returns artist's representative album's artwork, stored locally or from the web.
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void)
    
    /// Returns URL for artist's representative album's artwork.
    func artworkUrl(for size: ImageSize) -> URL?
    
    func artwork(for size: ImageSize) -> UIImage?
    
    var addedDate: Date? { get }
    
    var externalUrl: URL? { get }
}

extension AWArtist {
    func equals(_ other: AWArtist) -> Bool {
        return source == other.source && albumArtistUid == other.albumArtistUid
    }
    
    func getImage(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        artwork(for: size, completion: completion)
    }
    
    var sortAlbumArtistName: String {
        return albumArtistName.dropArticle()
    }
}
