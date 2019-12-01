//
//  Album+AWAlbum.swift
//  Plum
//
//  Created by adam.wienconek on 28.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension SimplifiedAlbum: AWAlbum {
    var source: AWMediaSource {
        return .spotify
    }
    
    var albumName: String {
        return name
    }
    
    var albumUid: String {
        return uid
    }
    
    var albumArtistName: String {
        if albumType == "compilation" && artists.first?.name.lowercased() == "various artists" {
            return LocalizedStringKey.variousArtists.localized
        } else {
            return artists.first?.name ?? LocalizedStringKey.unknownArtist.localized
        }
    }
    
    var albumArtistUid: String {
        if albumType == "compilation" && artists.first?.name.lowercased() == "various artists" {
            return .variousArtistsUid
        } else {
            return artists.first!.uid
        }
    }
    
    var releaseYear: String? {
        return releaseDate?.components(separatedBy: "-").first
    }
    
    var albumGenre: String? {
        return nil
    }
    
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        guard let url = artworkUrl(for: size) else {
            completion(nil)
            return
        }
        UIImage.getImage(from: url, completion: completion)
    }
    
    func artwork(for size: ImageSize) -> UIImage? {
        return nil
    }
    
    func artworkUrl(for size: ImageSize) -> URL? {
        return images.url(for: size)
    }
    
    var addedDate: Date? {
        return ISO8601DateFormatter().date(from: addedAt ?? "")
    }
    
    var externalUrl: URL? {
        guard let value = externalUrls["spotify"],
            let url = URL(string: value) else { return nil }
        return url
    }
    
}
