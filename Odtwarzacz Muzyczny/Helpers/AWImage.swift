//
//  Image.swift
//  Plum
//
//  Created by Adam Wienconek on 14.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

struct AWImage {
    let image: UIImage
    let size: ImageSize
    let isAsset: Bool
    let isArtwork: Bool
    
    init(image: UIImage, size: ImageSize, isAsset: Bool = false, isArtwork: Bool = false) {
        self.image = image
        self.size = size
        self.isAsset = isAsset
        self.isArtwork = isArtwork
    }
    
//    init(asset: AWAsset) {
//        image = asset.image
//        size = .large
//        isAsset = true
//        isArtwork = false
//    }
}
