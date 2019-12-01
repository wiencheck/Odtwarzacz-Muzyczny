//
//  MPMediaItemCollection.swift
//  Plum
//
//  Created by adam.wienconek on 27.11.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import MediaPlayer

extension MPMediaItemCollection {
    func filteredItems(cloud: Bool, drm: Bool) -> [MPMediaItem] {
        var filteredItems = items
        if !cloud {
            filteredItems = filteredItems.filter({ !$0.isCloudItem })
        }
        if !drm {
            filteredItems = filteredItems.filter({ !$0.hasProtectedAsset })
        }
        return filteredItems
    }
    
    /// Shows whether collection contains items by multiple artists.
    var isMultipleArtists: Bool {
        return items.first(where: { $0.artist != self.representativeItem?.artist }) != nil
    }
    
    open var repItem: MPMediaItem {
        return items.first(where: { $0.artwork != nil }) ?? representativeItem ?? items.first!
    }
}
