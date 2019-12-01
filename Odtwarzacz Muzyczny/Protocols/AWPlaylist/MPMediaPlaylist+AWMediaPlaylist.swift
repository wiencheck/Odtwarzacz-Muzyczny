//
//  MPMediaPlaylist+AWPlaylist.swift
//  Plum
//
//  Created by adam.wienconek on 07.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import MediaPlayer

extension MPMediaPlaylist: AWPlaylist {
    var source: AWMediaSource {
        return .iTunes
    }
    
    var playlistName: String {
        return name ?? LocalizedStringKey.unknownPlaylist.localized
    }
    
    var playlistUid: String {
        return String(describing: persistentID)
    }
    
    var trackCount: Int {
        return count
    }
    
    var playlistDescription: String? {
        return descriptionText
    }
    
    func imageUrl(for size: ImageSize) -> URL? {
        return nil
    }
    
    func image(for size: ImageSize, attributed: Bool, completion: @escaping (UIImage?) -> Void) {
        completion(image(for: size, attributed: attributed))
    }
    
    var attribute: PlaylistAttribute {
        if isFolder { return .folder }
        if parentPersistentID != nil { return .child }
        if isGenius { return .genius }
        if isSmart { return .smart }
        return .private
    }
    
    var user: String? {
        return nil
    }
    
    var externalUrl: URL? {
        return nil
    }
    
    func add(tracks: [AWTrack], completion: ((Error?) -> Void)?) {
        guard let items = tracks as? [MPMediaItem] else {
            print("*** Could not add tracks because they're not a MPMediaItem ***")
            return
        }
        let comp = completion ?? { error in
            if let error = error {
                let message = AWMessage(with: error)
                AWNotificationManager.post(notification: .failure(message))
            } else {
                let message = AWMessage(title: LocalizedStringKey.addedToPlaylist.localized)
                AWNotificationManager.post(notification: .success(message))
            }
        }
        add(items, completionHandler: comp)
    }
}
