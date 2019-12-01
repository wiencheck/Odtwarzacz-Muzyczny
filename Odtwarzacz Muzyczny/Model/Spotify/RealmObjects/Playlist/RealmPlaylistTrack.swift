//
//  RealmPlaylistTrack.swift
//  Plum
//
//  Created by Adam Wienconek on 09.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift

@objcMembers class RealmPlaylistTrack: Object, AWTrack {
    
    dynamic var _source: String = ""
    var source: AWMediaSource {
        return AWMediaSource.factory(from:  _source)
    }
    
    dynamic var _trackName: String = ""
    var trackName: String {
        return _trackName
    }
    
    dynamic var _trackUid: String = ""
    var trackUid: String {
        return _trackUid
    }
    
    dynamic var _playableUrl: String? = ""
    var playableUrl: String? {
        return _playableUrl
    }
    
    dynamic var _duration: TimeInterval = 0
    var duration: TimeInterval {
        return _duration
    }
    
    let _discNumber = RealmOptional<Int>()
    func discNumber() -> Int? {
        return _discNumber.value
    }
    
    let _trackNumber = RealmOptional<Int>()
    func trackNumber() -> Int? {
        return _trackNumber.value
    }
    
    var imagesURLs = List<String>()
    
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        guard let url = artworkUrl(for: size) else {
            completion(nil)
            return
        }
        UIImage.getImage(from: url, completion: completion)
    }
    
    func artworkUrl(for size: ImageSize) -> URL? {
        switch size {
        case .large:
            guard let url = imagesURLs.first else { return nil }
            return URL(string: url)
        case .medium:
            // TODO
            if let url = imagesURLs[1] as? String {
                return URL(string: url)
            }
            guard let url = imagesURLs.first else {
                return nil
            }
            return URL(string: url)
        case .small:
            guard let url = imagesURLs.last else { return nil }
            return URL(string: url)
        }
    }
    
    func artwork(for size: ImageSize) -> UIImage? {
        return nil
    }
    
    func lyrics(completion: @escaping (String?) -> Void) {
        completion(nil)
    }
    
    dynamic var _albumUid: String = ""
    var albumUid: String {
        return _albumUid
    }
    
    dynamic var _albumName: String = ""
    var albumName: String {
        return _albumName
    }
    
    dynamic var _artistUid: String = ""
    var artistUid: String {
        return _artistUid
    }
    
    dynamic var _artistName: String = ""
    var artistName: String {
        return _artistName
    }
    
    dynamic var _albumArtistName: String = ""
    var albumArtistName: String {
        return _albumArtistName
    }
    
    dynamic var _albumArtistUid: String = ""
    var albumArtistUid: String {
        return _albumArtistUid
    }
    
    dynamic var _userRating: Int = 0
    var userRating: Int {
        get {
            return _userRating
        } set {
            _userRating = newValue
        }
    }
    
    var available: Bool {
        return isInvalidated == false
    }
    
    var addedDate: Date? {
        return nil 
    }
    
    dynamic var _externalUrl: String? = nil
    var externalUrl: URL? {
        guard let _externalUrl = _externalUrl else { return nil }
        return URL(string: _externalUrl)
    }
    
    let playlists = List<RealmPlaylist>()
    
    dynamic var shouldBeDeleted: Bool = false
    
    override class func primaryKey() -> String? {
        return "_trackUid"
    }
}

