//
//  SPTAlbum.swift
//  Plum
//
//  Created by Adam Wienconek on 17/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

protocol SPTAlbum {
    var externalLink: URL? { get }
}

extension SimplifiedAlbum: SPTAlbum {
    var externalLink: URL? {
        return externalUrl
    }
}

extension RealmAlbum: SPTAlbum {
    var externalLink: URL? {
        return externalUrl
    }
}
