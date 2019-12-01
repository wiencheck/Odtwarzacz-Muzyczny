//
//  RealmAlbum.swift
//  Plum
//
//  Created by Adam Wienconek on 20.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift

@objcMembers class RealmAlbum: MyRealmObject, AWAlbum {
    
    dynamic var _source: String = ""
    var source: AWMediaSource {
        if isInvalidated { return .spotify }
        return AWMediaSource.factory(from:  _source)
    }
    
    dynamic var _albumName: String = ""
    var albumName: String {
        if isInvalidated { return LocalizedStringKey.unknownAlbum.localized }
        return _albumName
    }
    
    dynamic var _albumUid: String = ""
    var albumUid: String {
        if isInvalidated { return Constants.unknownAlbumUid }
        return _albumUid
    }
    
    dynamic var _albumArtistName: String = ""
    var albumArtistName: String {
        if isInvalidated { return LocalizedStringKey.unknownArtist.localized }
        return _albumArtistName
    }
    
    dynamic var _albumArtistUid: String = ""
    var albumArtistUid: String {
        if isInvalidated { return Constants.unknownArtistUid }
        return _albumArtistUid
    }
    
    dynamic var _releaseYear: String? = nil
    var releaseYear: String? {
        if isInvalidated { return nil }
        return _releaseYear
    }
    
    dynamic var _genre: String? = nil
    var albumGenre: String? {
        if isInvalidated { return nil }
        return _genre
    }
    
    dynamic var _trackCount: Int = 0
    
    dynamic var _addedDate: Date? = nil
    var addedDate: Date? {
        return _addedDate
    }
    
    dynamic var _externalUrl: String? = nil
    var externalUrl: URL? {
        guard let _externalUrl = _externalUrl else { return nil }
        return URL(string: _externalUrl)
    }
    
    var imagesURLs = List<String>()
        
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        guard let url = artworkUrl(for: size) else {
            completion(nil)
            return
        }
        UIImage.getImage(from: url, completion: completion)
    }
    
    func artwork(for size: ImageSize) -> UIImage? {
        return nil
    }
    
    func artworkUrl(for size: ImageSize) -> URL? {
        if isInvalidated { return nil }
        switch size {
        case .large:
            guard let url = imagesURLs.first else { return nil }
            return URL(string: url)
        case .medium:
            // TODO
            guard imagesURLs.count > 0 else {
                return nil
            }
            return URL(string: imagesURLs[1])
        case .small:
            guard let url = imagesURLs.last else { return nil }
            return URL(string: url)
        }
    }
        
    override class func primaryKey() -> String? {
        return "_albumUid"
    }
    
}