//
//  RealmPlaylistFolder.swift
//  Plum
//
//  Created by Adam Wienconek on 06/09/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift

@objcMembers class RealmPlaylistFolder: Object, AWPlaylist {
    
    dynamic var _source: String = ""
    var source: AWMediaSource {
        if isInvalidated { return .spotify }
        return AWMediaSource.factory(from:  _source)
    }
    
    dynamic var _playlistUid: String = ""
    var playlistUid: String {
        if isInvalidated { return Constants.unknownPlaylistUid }
        return _playlistUid
    }
    
    dynamic var _playlistName: String = ""
    var playlistName: String {
        if isInvalidated { return LocalizedStringKey.unknownPlaylist.localized }
        return _playlistName
    }
    
    var playlistDescription: String? {
        return nil
    }
    
    var trackCount: Int {
        if isInvalidated { return 0 }
        return children.sum(ofProperty: "_trackCount")
    }
    
    var attribute: PlaylistAttribute {
        return .folder
    }
    
    func image(for size: ImageSize, attributed: Bool, completion: @escaping (UIImage?) -> Void) {
        if attributed {
            completion(UIImage(systemName: "folder"))
            return
        }
        guard let url = imageUrl(for: size) else {
            completion(nil)
            return
        }
        UIImage.getImage(from: url, completion: completion)
    }
    
    func imageUrl(for size: ImageSize) -> URL? {
        if isInvalidated { return nil }
        switch size {
        case .large:
            return imagesURLs.first
        case .medium:
            return imagesURLs.at(1)
        case .small:
            return imagesURLs.last
        }
    }
    
    func image(for size: ImageSize, attributed: Bool) -> UIImage? {
        return nil
    }
    
    var user: String? {
        return nil
    }
    
    let children = LinkingObjects(fromType: RealmPlaylist.self, property: "parent")
    
    var imagesURLs: [URL] {
        return children.compactMap {
            $0.imageUrl(for: .small)
        }
    }
    
    dynamic var _externalUrl: String? = nil
    var externalUrl: URL? {
        guard let _externalUrl = _externalUrl else { return nil }
        return URL(string: _externalUrl)
    }
    
    dynamic var shouldBeDeleted: Bool = false
    
    override class func primaryKey() -> String? {
        return "_playlistUid"
    }
    
    func add(tracks: [AWTrack], completion: ((Error?) -> Void)?) {
        print("*** Adding to Folder is not supported ***")
    }
    
}
