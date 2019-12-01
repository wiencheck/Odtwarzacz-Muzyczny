//
//  AWPlaylist.swift
//  Plum
//
//  Created by adam.wienconek on 07.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

protocol AWPlaylist {
    var source: AWMediaSource { get }
    
    var playlistUid: String { get }
    
    var playlistName: String { get }
    
    var playlistDescription: String? { get }
    
    var trackCount: Int { get }
        
    var isModifiable: Bool { get }
    
    var attribute: PlaylistAttribute { get }
    
    var user: String? { get }
    
    var externalUrl: URL? { get }
    
    func image(for size: ImageSize, attributed: Bool, completion: @escaping (UIImage?) -> Void)
    
    func imageUrl(for size: ImageSize) -> URL?
    
    func image(for size: ImageSize, attributed: Bool) -> UIImage?
    
    func add(tracks: [AWTrack], completion: ((Error?) -> Void)?)
}

extension AWPlaylist {
    var isModifiable: Bool {
        return attribute == .private
    }
    
    func equals(_ other: AWPlaylist) -> Bool {
        return source == other.source && playlistUid == other.playlistUid
    }
}
