//
//  RealmTrack.swift
//  Plum
//
//  Created by Adam Wienconek on 20.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift

@objcMembers class RealmTrack: MyRealmObject, AWTrack {
    
    dynamic var _source: String = ""
    var source: AWMediaSource {
        if isInvalidated { return .spotify }
        return AWMediaSource.factory(from:  _source)
    }
    
    dynamic var _trackName: String = ""
    var trackName: String {
        if isInvalidated { return LocalizedStringKey.unknownTitle.localized }
        return _trackName
    }
    
    dynamic var _trackUid: String = ""
    var trackUid: String {
        if isInvalidated { return Constants.unknownTrackUid }
        return _trackUid
    }
    
    dynamic var _albumUid: String = ""
    var albumUid: String {
        if isInvalidated { return Constants.unknownAlbumUid }
        return _albumUid
    }
    
    dynamic var _albumName: String = ""
    var albumName: String {
        if isInvalidated { return LocalizedStringKey.unknownAlbum.localized }
        return _albumName
    }
    
    dynamic var _artistName: String = ""
    var artistName: String {
        if isInvalidated { return LocalizedStringKey.unknownArtist.localized }
        return _artistName
    }
    
    dynamic var _albumArtistName: String = ""
    var albumArtistName: String {
        if isInvalidated { return LocalizedStringKey.unknownArtist.localized }
        return _albumArtistName
    }
    
    dynamic var _artistUid: String = ""
    var artistUid: String {
        if isInvalidated { return Constants.unknownArtistUid }
        return _artistUid
    }
    
    dynamic var _albumArtistUid: String = ""
    var albumArtistUid: String {
        if isInvalidated { return Constants.unknownArtistUid }
        return _albumArtistUid
    }
    
    dynamic var _playableUrl: String? = nil
    var playableUrl: String? {
        if isInvalidated { return nil }
        return _playableUrl
    }
    
    dynamic var _duration: TimeInterval = 0
    var duration: TimeInterval {
        if isInvalidated { return 0 }
        return _duration
    }
    
    var imagesURLs = List<String>()
    
    func artworkUrl(for size: ImageSize) -> URL? {
        if isInvalidated { return nil }
        switch size {
        case .large:
            guard let url = imagesURLs.first else { return nil }
            return URL(string: url)
        case .medium:
            guard imagesURLs.count > 0 else {
                return nil
            }
            return URL(string: imagesURLs[1])
//            if let url = imagesURLs[1] as? String {
//                return URL(string: url)
//            }
//            guard let url = imagesURLs.first else {
//                return nil
//            }
//            return URL(string: url)
        case .small:
            guard let url = imagesURLs.last else { return nil }
            return URL(string: url)
        }
    }
    
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
    
    dynamic var _lyrics: String? = nil
    func lyrics(completion: @escaping (String?) -> Void) {
        completion(_lyrics)
    }
    
    let _discNumber = RealmOptional<Int>()
    func discNumber() -> Int? {
        if isInvalidated { return nil }
        return _discNumber.value
    }
    
    let _trackNumber = RealmOptional<Int>()
    func trackNumber() -> Int? {
        if isInvalidated { return nil }
        return _trackNumber.value
    }
    
    dynamic var _userRating: Int = 0
    var userRating: Int {
        get {
            return _userRating
        } set {
            _userRating = newValue
        }
    }
    
    dynamic var _addedDate: Date? = nil
    var addedDate: Date? {
        return _addedDate
    }
    
    dynamic var _externalUrl: String? = nil
    var externalUrl: URL? {
        guard let _externalUrl = _externalUrl else { return nil }
        return URL(string: _externalUrl)
    }
    
    var available: Bool {
        return isInvalidated == false
    }
        
    override class func primaryKey() -> String? {
        return "_trackUid"
    }
} 
