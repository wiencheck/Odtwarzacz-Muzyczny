//
//  MPMediaPlaylist.swift
//  Musico
//
//  Created by adam.wienconek on 24.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import MediaPlayer

extension MPMediaPlaylist {
    
    func image(for size: ImageSize, attributed: Bool) -> UIImage? {
        if attributed {
            switch attribute {
            case .folder:
                return UIImage(systemName: "folder")
            case .smart:
                return UIImage(systemName: "gear")
            default:
                break
            }
        }
        return image(from: 4, at: size.cgSize)
    }
    
    func image(from count: Int, cloud: Bool = false, drm: Bool = false, at outputSize: CGSize) -> UIImage? {
        let maxImageCount = max(1, min(9, count))
        var representativeArtworks = [MPMediaEntityPersistentID: UIImage]()
        for item in filteredItems(cloud: cloud, drm: drm) {
            guard representativeArtworks.count <= maxImageCount, !representativeArtworks.keys.contains(item.albumArtistPersistentID), let artwork = item.artworkx100 else { continue }
            representativeArtworks.updateValue(artwork, forKey: item.albumArtistPersistentID)
        }
        let images = [UIImage](representativeArtworks.values)
        return AWMediaImageFetcher.combineImages2(images: images, outputSize: outputSize)
    }
    
    var isEditable: Bool {
        return value(forProperty: "isEditable") as? Bool ?? false
    }
    
    var isFolder: Bool {
        return value(forProperty: "isFolder") as? Bool ?? false
    }
    
    var parentPersistentID: MPMediaEntityPersistentID? {
        let parent = (value(forProperty: "parentPersistentID") as? NSNumber)?.uint64Value
        return parent == 0 ? nil : parent
    }
    
    var isSmart: Bool {
        return playlistAttributes.contains(.smart)
    }
    
    var isGenius: Bool {
        return playlistAttributes.contains(.genius)
    }
}
