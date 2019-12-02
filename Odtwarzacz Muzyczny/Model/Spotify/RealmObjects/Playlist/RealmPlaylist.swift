//
//  RealmPlaylist.swift
//  Plum
//
//  Created by Adam Wienconek on 20.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift
import Spartan

@objcMembers class RealmPlaylist: MyRealmObject, AWPlaylist {
    
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
    
    dynamic var _playlistDescription: String? = nil
    var playlistDescription: String? {
        if isInvalidated { return nil }
        return _playlistDescription
    }
    
    dynamic var _trackCount: Int = 0
    var trackCount: Int {
        if isInvalidated { return 0 }
        // 'track' will be empty until the playlist is fetched for the first time.
        let valid = validTracks().count
        if valid > 0 {
            return valid
        }
        return _trackCount
    }
    
    dynamic var _attribute: Int = 0
    var attribute: PlaylistAttribute {
        if isInvalidated { return .private }
        if parent != nil {
            return .child
        } else {
            return PlaylistAttribute(rawValue: _attribute)!
        }
    }
    
    func image(for size: ImageSize, attributed: Bool, completion: @escaping (UIImage?) -> Void) {
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
    
    func image(for size: ImageSize, attributed: Bool) -> UIImage? {
        return nil
    }
    
    dynamic var _user: String? = nil
    var user: String? {
        return _user
    }
    
    dynamic var _externalUrl: String? = nil
    var externalUrl: URL? {
        guard let _externalUrl = _externalUrl else { return nil }
        return URL(string: _externalUrl)
    }
    
    let tracks = LinkingObjects(fromType: RealmPlaylistTrack.self, property: "playlists")
    
    func validTracks() -> [RealmPlaylistTrack] {
        let predicate = NSPredicate(format: "shouldBeDeleted == NO")
        let filtered = tracks.filter(predicate)
        return Array(filtered)
    }
    
    dynamic var parent: RealmPlaylistFolder?
    
    let imagesURLs = List<String>()
    
    func add(tracks: [AWTrack], completion: ((Error?) -> Void)?) {
        guard let user = SpotifyManager.user else {
            
            return
        }
        guard let items = tracks as? [SpotifyTrack] else {
            
            return
        }
        let uris = items.map({ $0.uri() })
        Spartan.addTracksToPlaylist(userId: user, playlistId: playlistUid, trackUris: uris, success: { _ in
            if let playlistTracks = tracks as? [RealmPlaylistTrack] {
                let realm = self.realm ?? Realm.create()
                try? realm.write {
                    playlistTracks.forEach { track in
                        track.playlists.append(self)
                    }
                }
            }
            completion?(nil)
        }) { error in
            completion?(error)
        }
    }
        
    override class func primaryKey() -> String? {
        return "_playlistUid"
    }
    
}
