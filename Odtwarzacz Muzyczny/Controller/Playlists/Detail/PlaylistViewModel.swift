//
//  PlaylistsDetailViewModel.swift
//  Musico
//
//  Created by adam.wienconek on 21.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

protocol PlaylistsDetailViewModelDelegate: class, Errorable, Alertable, Loadable {
    func modelDidUpdate()
    func didReloadRow(at path: IndexPath, successfully: Bool)
    func didFindItem(at index: Int)
}

class PlaylistsDetailViewModel {
    
    private let repo: NewRepo
    private let player: AWPlayer
    
    let minimumCountForIndex = 32
    
    let playlistTitle: String
    
    var items: [AWTrack] = []
    
    weak var playlist: AWConcretePlaylist!
    
    weak var delegate: PlaylistsDetailViewModelDelegate?

    var queueCellPath: IndexPath?
    let shuffleCellPath = IndexPath(row: 1, section: 0)
    
    init(playlist: AWConcretePlaylist) {
        player = AppContext.shared.player
        repo = AppContext.shared.newRepo
        self.playlist = playlist
        playlistTitle = playlist.playlistName
        updateResults(with: playlist.items)
        
        NotificationCenter.default.addObserver(forName: NewRepo.playlistDidUpdateNotification, object: nil, queue: nil) { notification in
            guard let identifier = notification.object as? String,
               self.playlist.playlistUid == identifier else { return }
            DispatchQueue.main.async {
                self.fetchItems()
            }
        }
    }
    
    deinit {
        print("\(String(describing: self)) deinitialized")
    }
    
    private func fetchItems() {
        items = []
        repo.getTracksForPlaylist(identifier: playlist.playlistUid, from: playlist.source) { result in
            switch result {
            case .success(let tracks):
                self.updateResults(with: tracks)
            case .failure(let error):
                self.delegate?.didEncounterError(error)
            }
        }
    }
    
    private func updateResults(with tracks: AWTrackCollection) {
        items.append(contentsOf: tracks)
    }
    
    private var preferredImageSize: ImageSize {
        return NetworkMonitor.shared.isReducingDataUsage ? .small : .medium
    }
    
    
    var numberOfSections: Int {
        return 1
    }
        
    func numberOfRows(for section: Int) -> Int {
        return items.count
    }
    
    func getTrack(at path: IndexPath) -> AWTrack? {
        return items.at(path.row)
    }
    
    func cellViewModel(for path: IndexPath) -> CellViewModel? {
        guard let item = getTrack(at: path) else { return nil }
        
        let title = item.trackName
        let detail = item.artistName
        let secondaryDetail = item.albumName
        let rightDetail = item.duration.asString
        let image = UIImage(systemName: "music.note")!
        let imageUrl = item.artworkUrl(for: .small)
        
        return CellViewModel(title: title, detail: detail, secondaryDetail: secondaryDetail, rightDetail: rightDetail, mainImage: image, imageUrl: imageUrl, detailSeparator: String(Character.SpecialCharacters.dot_middle))
    }
    
    func getImage(for path: IndexPath, at size: ImageSize, completion: @escaping (UIImage?) -> Void) {
        guard let item = getTrack(at: path),
               item.artworkUrl(for: size) == nil else { return }
        DispatchQueue.main.async {
            item.artwork(for: size, completion: completion)
        }
    }
    
    func didSelectRow(at path: IndexPath) {
        if shouldDisplayQueueCell(for: path) {
            unloadQueueCell(false)
            loadQueueCell(for: path)
            return
        }
        switch path {
        case shuffleCellPath:
            didPressShuffle()
        default:
            guard let item = getTrack(at: path) else {
                return
            }
            player.setOriginalQueue(with: items, description: playlist.playlistName, identifier: .playlist(playlist.playlistUid))
            player.setNowPlayingItem(item)
            player.setQueue()
            player.play()
        }
    }
    
    func didPressShuffle() {
        player.setShuffle(true)
//        player.setQueue(items: items, description: playlist.playlistName, identifier: .playlist(playlist.playlistUid)) { index, model in
//            self.delegate?.didFindItem(at: index)
//            self.delegate?.didReceiveAlert(model: model)
//        }
    }
        
    func shouldDisplayQueueCell(for path: IndexPath) -> Bool {
        return player.isPlaying && path != shuffleCellPath
    }
    
    func loadQueueCell(for path: IndexPath) {
        queueCellPath = path
        delegate?.didReloadRow(at: path, successfully: false)
    }
    
    func unloadQueueCell(_ success: Bool) {
        if let queuePath = queueCellPath {
            queueCellPath = nil
            delegate?.didReloadRow(at: queuePath, successfully: success)
        }
    }
    
    func handleAddNextPressed(at path: IndexPath) {
        player.addNext(getTrack(at: path))
    }
    
    func handleAddLastPressed(at path: IndexPath) {
        player.addLast(getTrack(at: path))
    }
    
}

extension PlaylistsDetailViewModel: QueueCellDelegate {
    func queueCell(playNowPressed in: QueueTableViewCell) {
        if let queuePath = queueCellPath, let item = getTrack(at: queuePath) {
            player.setOriginalQueue(with: items, description: playlist.playlistName, identifier: .playlist(playlist.playlistUid))
            player.setNowPlayingItem(item)
            player.setQueue()
            player.play()
            unloadQueueCell(true)
        } else {
            unloadQueueCell(false)
        }
    }

    func queueCell(playNextressed in: QueueTableViewCell) {
        if let queuePath = queueCellPath {
            handleAddNextPressed(at: queuePath)
            unloadQueueCell(true)
        } else {
            unloadQueueCell(false)
        }
    }

    func queueCell(playLastPressed in: QueueTableViewCell) {
        if let queuePath = queueCellPath {
            handleAddLastPressed(at: queuePath)
            unloadQueueCell(true)
        } else {
            unloadQueueCell(false)
        }
    }
}
