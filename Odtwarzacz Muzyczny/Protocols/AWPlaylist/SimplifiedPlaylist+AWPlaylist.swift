//
//  SimplifiedPlaylist+AWPlaylist.swift
//  Plum
//
//  Created by adam.wienconek on 29.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension SimplifiedPlaylist: AWPlaylist {
    var source: AWMediaSource {
        return .spotify
    }
    
    var playlistUid: String {
        return uid
    }
    
    var playlistName: String {
        return name
    }
    
    var playlistDescription: String? {
        guard let ownerName = owner.displayName else {
            return nil
        }
        return LocalizedStringKey.playlistDescriptionCreatedBy.localized + " " + ownerName
    }
    
    var trackCount: Int {
        return tracksObject.total
    }
    
    func imageUrl(for size: ImageSize) -> URL? {
        return images.url(for: size)
    }
    
    func image(for size: ImageSize, attributed: Bool, completion: @escaping (UIImage?) -> Void) {
        guard let url = imageUrl(for: size) else { return }
        UIImage.getImage(from: url, completion: completion)
    }
    
    func image(for size: ImageSize, attributed: Bool) -> UIImage? {
        return nil
    }
    
    var attribute: PlaylistAttribute {
        if let user = user, let savedUser = SpotifyManager.shared.user,
            user == savedUser {
            return .private
        }
        return .shared
    }
        
    var user: String? {
        return owner.canonicalUsername
    }
    
    var externalUrl: URL? {
        guard let value = externalUrls["spotify"],
            let url = URL(string: value) else { return nil }
        return url
    }
    
    func add(tracks: [AWTrack], completion: ((Error?) -> Void)?) {
        guard let user = SpotifyManager.shared.user else {
            
            return
        }
        guard let items = tracks as? [SpotifyTrack] else {
            
            return
        }
        let uris = items.map({ $0.uri() })
        let comp = completion ?? { error in
            if let error = error {
                let message = AWMessage(with: error)
                AWNotificationManager.post(notification: .failure(message))
            } else {
                let message = AWMessage(title: LocalizedStringKey.addedToPlaylist.localized)
                AWNotificationManager.post(notification: .success(message))
            }
        }
        Spartan.addTracksToPlaylist(userId: user, playlistId: playlistUid, trackUris: uris, success: { _ in
            comp(nil)
        }) { error in
            comp(error)
        }
    }
}
