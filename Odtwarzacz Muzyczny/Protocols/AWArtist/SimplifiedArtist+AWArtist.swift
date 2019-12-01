//
//  SimplifiedArtist+AWArtist.swift
//  Plum
//
//  Created by Adam Wienconek on 10.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension SimplifiedArtist: AWArtist {
    var source: AWMediaSource {
        return .spotify
    }
    
    var albumArtistUid: String {
        return uid
    }
    
    var albumArtistName: String {
        return name
    }
    
    func artwork(for size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        guard let url = artworkUrl(for: size) else {
            completion(nil)
            return
        }
        UIImage.getImage(from: url) { image in
            completion(image)
        }
    }
    
    func artworkUrl(for size: ImageSize) -> URL? {
        return albumImages?.url(for: size)
    }
    
    func artwork(for size: ImageSize) -> UIImage? {
        return nil
    }
    
    var addedDate: Date? {
        return nil
    }
    
    var externalUrl: URL? {
        return nil
//        guard let value = externalUrls["spotify"],
//            let url = URL(string: value) else { return nil }
//        return url
    }
}
