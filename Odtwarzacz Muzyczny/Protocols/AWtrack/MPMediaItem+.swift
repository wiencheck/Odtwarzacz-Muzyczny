//
//  MPMediaItem+.swift
//  Plum
//
//  Created by Adam Wienconek on 21.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import MediaPlayer

extension MPMediaItem: AWTrack, AWAlbum, AWArtist {
    var trackUid: String {
        return String(describing: persistentID)
    }
    
    var source: AWMediaSource {
        return .iTunes
    }
    
    var trackName: String {
        return title ?? LocalizedStringKey.unknownTitle.localized
    }
    
    func artworkUrl(for size: ImageSize) -> URL? {
        return nil
    }
    
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        let image = artwork(for: size)
        completion(image)
    }
    
    func artwork(for size: ImageSize) -> UIImage? {
        return artwork?.image(at: size.cgSize)
    }
    
    var duration: TimeInterval {
        return playbackDuration
    }
    
    func discNumber() -> Int? {
        guard discNumber > 0 else {
            return nil
        }
        return discNumber
    }
    
    func trackNumber() -> Int? {
        guard albumTrackNumber > 0 else {
            return nil
        }
        return albumTrackNumber
    }
    
    var playableUrl: String? {
        return assetURL?.absoluteString
    }
    
    var sortName: String {
        return value(forProperty: "sortTitle") as? String ?? trackName.dropArticle()
    }
    
    func lyrics(completion: @escaping (String?) -> Void) {
        if let assetUrl = assetURL, let lyrics = AVAsset(url: assetUrl).lyrics {
            completion(lyrics)
        } else {
            completion(nil)
        }
    }
    
    var available: Bool {
        return isCloudItem == false
    }
    
    var addedDate: Date? {
        return self.perform(#selector(getter: MPMediaItem.dateAdded))?.takeUnretainedValue() as? Date
    }
    
    var albumUid: String {
        return String(albumPersistentID)
    }
    
    var albumName: String {
        return albumTitle ?? LocalizedStringKey.unknownAlbum.localized
    }
    
    var albumArtistUid: String {
        if isCompilation {
            return .variousArtistsUid
        }
        return String(albumArtistPersistentID)
    }
    
    var albumArtistName: String {
        if isCompilation {
            return LocalizedStringKey.variousArtists.localized
        }
        return albumArtist ?? LocalizedStringKey.unknownArtist.localized
    }
    
    var albumGenre: String? {
        let separators = [",", "/", "& "]
        for c in separators {
            guard let com = genre?.components(separatedBy: c), com.count > 1 else { continue }
            return com.first
        }
        return genre
    }
    
    var sortAlbumName: String {
        return value(forProperty: "sortAlbumName") as? String ?? albumName.dropArticle()
    }
    
    var sortAlbumArtistName: String {
        if isCompilation {
            return LocalizedStringKey.variousArtists.localized
        }
        return value(forProperty: "sortAlbumArtist") as? String ?? albumArtistName.dropArticle()
    }
    
    var artistName: String {
        return artist ?? LocalizedStringKey.unknownArtist.localized
    }
    
    var artistUid: String {
        return String(artistPersistentID)
    }
    
    var isInUserLibrary: Bool {
        return true
    }
    
    var externalUrl: URL? {
        return nil
    }
    
}
