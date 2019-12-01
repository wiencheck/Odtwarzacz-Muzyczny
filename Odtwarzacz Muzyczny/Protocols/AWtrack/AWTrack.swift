//
//  AWTrack.swift
//  Plum
//
//  Created by adam.wienconek on 07.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

protocol AWTrack {
    
    /// Type representing source of file
    var source: AWMediaSource { get }
    
    var trackName: String { get }
    
    /// Unique id of the item
    var trackUid: String { get }
    
    /// URL used for playback
    var playableUrl: String? { get }
    
    /// Playback duration of the item (in seconds)
    var duration: TimeInterval { get }
    
    /// Number of the disc containing the item.
    func discNumber() -> Int?
    
    /// Number of track on the disc
    func trackNumber() -> Int?
    
    /// String representing name of item's album
    var albumName: String { get }
    
    /// String representing name of item's artist
    var artistName: String { get }
    
    var albumArtistName: String { get }
    
    /// Item's title without prefix
    var sortName: String { get }
    
    /// Item's title without prefix
    var sortAlbumName: String { get }
    
    /// Item's title without prefix
    var sortArtistName: String { get }
    
    var sortAlbumArtistName: String { get }
    
    func artworkUrl(for size: ImageSize) -> URL?
        
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void)
    
    func artwork(for size: ImageSize) -> UIImage?
    
    func lyrics(completion: @escaping (String?) -> Void)
    
    /// Unique id of album containing the item
    var albumUid: String { get }
    
    /// Unique id of album artist
    var artistUid: String { get }
    
    var albumArtistUid: String { get }
    
    var addedDate: Date? { get }
        
    var userRating: Int { get set }
    
    func equals(_ other: AWTrack) -> Bool
    
    var available: Bool { get }
    
    var isInUserLibrary: Bool { get }
    
    var externalUrl: URL? { get }
}

extension AWTrack {
    func equals(_ other: AWTrack) -> Bool {
        return source == other.source && trackUid == other.trackUid
    }
    
    func lyrics(completion: @escaping (String?) -> Void) {
        completion(nil)
    }
    
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        guard let url = artworkUrl(for: size) else {
            completion(nil)
            return
        }
        UIImage.getImage(from: url, completion: completion)
    }
    
    var sortName: String {
        return trackName.dropArticle()
    }
    
    var sortAlbumName: String {
        return albumName.dropArticle()
    }
    
    var sortArtistName: String {
        return artistName.dropArticle()
    }
    
    var sortAlbumArtistName: String {
        return albumArtistName.dropArticle()
    }
    
    var isInUserLibrary: Bool {
        return RealmManager.existsInDatabase(self)
    }
}

typealias AWTrackCollection = [AWTrack]

extension Collection where Element == AWTrack {
    var representativeItem: AWTrack {
        if let item = first(where: { $0.artworkUrl(for: .small) != nil }) {
            return item
        } else if let item = first(where: { $0.artwork(for: .small) != nil }) {
            return item
        } else {
            return first!
        }
    }
}


extension Collection where Element: AWTrack {
    var representativeItem: AWTrack {
        return first(where: { $0.artworkUrl(for: .small) != nil }) ?? first!
    }
}
