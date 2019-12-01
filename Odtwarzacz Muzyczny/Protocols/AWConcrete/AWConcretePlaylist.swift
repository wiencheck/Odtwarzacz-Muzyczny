//
//  AWConcretePlaylist.swift
//  Plum
//
//  Created by Adam Wienconek on 25.05.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

class AWConcretePlaylist: AWPlaylist, AWConcreteMediaCollection {

    var items: [AWTrack]
    private var playlist: AWPlaylist?
    var image: AWImage?
    
    init(playlistName: String, source: AWMediaSource, playlistDescription: String?, playlistUid: String, attribute: PlaylistAttribute, user: String?, externalUrl: URL?, items: [AWTrack], image: AWImage? = nil) {
        self.playlistName = playlistName
        self.source = source
        self.playlistDescription = playlistDescription
        self.playlistUid = playlistUid
        self.attribute = attribute
        self.user = user
        self.externalUrl = externalUrl
        self.items = items
        self.image = image
    }
    
    convenience init(playlist: AWPlaylist, items: [AWTrack]) {
        self.init(playlistName: playlist.playlistName, source: playlist.source, playlistDescription: playlist.playlistDescription, playlistUid: playlist.playlistUid, attribute: playlist.attribute, user: playlist.user, externalUrl: playlist.externalUrl, items: items)
        self.playlist = playlist
    }
        
    let source: AWMediaSource
    
    var playlistUid: String
    
    var playlistName: String
    
    var playlistDescription: String?
    
    var trackCount: Int {
        return items.count
    }
    
    var isModifiable: Bool {
        return false
    }
    
    var attribute: PlaylistAttribute
    
    var user: String?
    
    var externalUrl: URL?
    
    func image(for size: ImageSize, attributed: Bool, completion: @escaping (UIImage?) -> Void) {
        if let playlist = playlist {
            playlist.image(for: size, attributed: attributed, completion: completion)
            return
        }
        completion(nil)
    }
    
    func imageUrl(for size: ImageSize) -> URL? {
        return playlist?.imageUrl(for: size)
    }
    
    func image(for size: ImageSize, attributed: Bool) -> UIImage? {
        return playlist?.image(for: size, attributed: attributed)
    }
    
    func add(tracks: [AWTrack], completion: ((Error?) -> Void)?) {
        playlist?.add(tracks: tracks, completion: completion)
    }
            
}
