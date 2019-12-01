//
//  RealmArtist.swift
//  Plum
//
//  Created by Adam Wienconek on 20.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift

@objcMembers class RealmArtist: MyRealmObject, AWArtist {
    
    dynamic var _source: String = ""
    var source: AWMediaSource {
        if isInvalidated { return .spotify }
        return AWMediaSource.factory(from:  _source)
    }
    
    dynamic var _artistUid: String = ""
    var albumArtistUid: String {
        if isInvalidated { return Constants.unknownArtistUid }
        return _artistUid
    }
    
    dynamic var _artistName: String = ""
    var albumArtistName: String {
        if isInvalidated { return LocalizedStringKey.unknownArtist.localized }
        return _artistName
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
    
    let tracks = List<RealmTrack>()
    
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        guard let url = artworkUrl(for: size) else {
            completion(nil)
            return
        }
        UIImage.getImage(from: url, completion: completion)
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
    
    func artwork(for size: ImageSize) -> UIImage? {
        return nil
    }
    
    override class func primaryKey() -> String? {
        return "_artistUid"
    }
}
