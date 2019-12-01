//
//  PlayerViewController.swift
//  Plum
//
//  Created by Adam Wienconek on 16.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

protocol PlayerViewControllerDelegate: class {
    func didSelectAlbum(identifier: String, source: AWMediaSource, image: AWImage?)
    func didSelectArtist(identifier: String, source: AWMediaSource, image: AWImage?)
    func didSelectPlaylist(identifier: String, source: AWMediaSource)
}
