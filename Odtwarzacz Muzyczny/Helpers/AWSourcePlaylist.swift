//
//  AWSourcePlaylist.swift
//  Plum
//
//  Created by Adam Wienconek on 27/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

class AWSourcePlaylist: AWPlaylist {
    
    var source: AWMediaSource
    
    var playlistUid: String {
        return source.rawValue
    }
    
    var playlistName: String {
        return source.rawValue
    }
    
    var playlistDescription: String? {
        return LocalizedStringKey.sourcedPlaylistDescription.localized + " " + source.rawValue
    }
    
    var trackCount: Int
    
    var attribute: PlaylistAttribute {
        return .sourced
    }
    
    var user: String? {
        return nil
    }
    
    var externalUrl: URL? {
        return nil
    }
    
    init(source: AWMediaSource, trackCount: Int) {
        self.source = source
        self.trackCount = trackCount
    }
    
    private var image: UIImage? {
        return UIImage(named: source.rawValue)
    }
    
    func image(for size: ImageSize, attributed: Bool, completion: @escaping (UIImage?) -> Void) {
        completion(image)
    }
    
    func imageUrl(for size: ImageSize) -> URL? {
        return nil
    }
    
    func image(for size: ImageSize, attributed: Bool) -> UIImage? {
        return image
    }
    
    func add(tracks: [AWTrack], completion: ((Error?) -> Void)?) {
        print("*** Adding to Source playlist is not supported ***")
    }
    
}
