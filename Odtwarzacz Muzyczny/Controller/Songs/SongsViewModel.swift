//
//  SongsMasterViewModel.swift
//  Musico
//
//  Created by adam.wienconek on 17.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import MediaPlayer

protocol SongsViewModelDelegate: class, Errorable, Loadable {
    func didUpdateModel()
    func didReloadRow(at path: IndexPath, successfully: Bool)
}

class SongsViewModel {
    
    private let context: AppContext
    private let repo: NewRepo
    private let player: AWPlayer
    
    private var selectedItem: AWTrack?
    
    var items: [AWTrack] {
        var _items = [AWTrack]()
        for index in sectionIndexes {
            guard let value = itemsDictionary[index] else { continue }
            _items.append(contentsOf: value)
        }
        return _items
    }
    
    weak var delegate: SongsViewModelDelegate?
    
    var itemsDictionary: [String: [AWTrack]] = [:]

    var sectionIndexes: [String] = []
    
    var queueCellPath: IndexPath?
    var isObservingLibraryChange = false
    
    var recentlyAddedItems: [AWTrack] = []
    var recentlyAddedSection = 0
    let recentlyAddedCompactCount = 4
    let recentlyAddedExpandedCount = 20
    var recentlyAddedExpanded = false
    
    init() {
        self.context = AppContext.shared
        self.repo = context.newRepo
        self.player = context.player
    }
    
    func fetchTracks() {
        context.newRepo.getAllSongs(from: [.iTunes, .spotify]) { [weak self] result in
            switch result {
            case .success(let tracks):
                self?.updateResults(with: tracks)
            case .failure(let error):
                self?.delegate?.didEncounterError(error)
            }
            if self?.isObservingLibraryChange == true { return }
            NotificationCenter.default.addObserver(forName: NewRepo.libraryDidUpdateNotification, object: nil, queue: .main) { notification in
                print("*** Notyfikacja że update w songs ***")
                self?.fetchTracks()
            }
            self?.isObservingLibraryChange = true
        }
    }
    
    private func updateResults(with tracks: AWTrackCollection) {
        sortIncoming(items: tracks)
    }
    
    func numberOfRows(for section: Int) -> Int {
        guard let index = sectionIndexes.at(section - 1), let count = itemsDictionary[index]?.count else {
            return 0
        }
        return count
    }
    
    var numberOfSections: Int {
        return sectionIndexes.count + 1
    }
    
    func cellViewModel(for path: IndexPath) -> CellViewModel? {
        guard let item = getItem(at: path) else { return nil }
        
        let title = item.trackName
        let detail = item.albumArtistName
        let secondaryDetail = item.albumName
        let image = UIImage(systemName: "music.note")!
        let imageUrl = item.artworkUrl(for: .small)
        
        return CellViewModel(title: title, detail: detail, secondaryDetail: secondaryDetail, mainImage: image, secondaryImage: nil, imageUrl: imageUrl)
    }
    
    func sectionTitle(for section: Int) -> String? {
        return sectionIndexes.at(section)
    }
    
    func getImage(for path: IndexPath, size: ImageSize, completion: ((UIImage) -> Void)?) {

        guard let item = getItem(at: path),
                item.artworkUrl(for: size) == nil else { return }
        DispatchQueue.main.async {
            item.artwork(for: size) { artwork in
                guard let artwork = artwork else { return }
                completion?(artwork)
            }
        }
    }
    
    private func getItem(at path: IndexPath) -> AWTrack? {
        switch path.section {
        case recentlyAddedSection:
            return recentlyAddedItems.at(path.row)
        default:
            guard let index = sectionIndexes.at(path.section - 1) else {
                return nil
            }
            return itemsDictionary[index]?[path.row]
        }
    }
    
    func shouldDisplayQueueCell(for path: IndexPath) -> Bool {
        return player.isPlaying
    }
    
    func didSelectRow(at path: IndexPath) {
        if shouldDisplayQueueCell(for: path) {
            unloadQueueCell(false)
            loadQueueCell(for: path)
        } else if let track = getItem(at: path) {
            player.setOriginalQueue(with: items, description: LocalizedStringKey.allSongs.localized)
            player.setNowPlayingItem(track)
            player.setQueue()
            player.play()
        }
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
        player.addNext(getItem(at: path))
    }
    
    func handleAddLastPressed(at path: IndexPath) {
        player.addLast(getItem(at: path))
    }
    
}

extension SongsViewModel: QueueCellDelegate {
    func queueCell(playNowPressed in: QueueTableViewCell) {
        if let queuePath = queueCellPath {
            guard let item = getItem(at: queuePath) else {
                return
            }
            player.setOriginalQueue(with: items, description: LocalizedStringKey.allSongs.localized)
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

extension SongsViewModel {
    func sortIncoming(items: [AWTrack]) {
        print("a teraz ja")
        var newIndexes = [String]()
        var newDict = [String: [AWTrack]]()
        
        func insertNewSection(item: AWTrack, key: String) {
            newIndexes.append(key)
            newDict.updateValue([item], forKey: key)
        }
        
        func insertNewRow(item: AWTrack, key: String) {
            newDict[key]!.append(item)
        }
        
        for item in items {
            let key = String(item.trackName.first ?? "?")
            if newDict[key] == nil {
                insertNewSection(item: item, key: key)
            } else {
                insertNewRow(item: item, key: key)
            }
        }
        
        print("po petli")
        
        newIndexes.sort(by: <)
        
        for index in newIndexes {
            newDict[index]?.sort(by: {
                $0.trackName < $1.trackName
            })
        }
        
        itemsDictionary = newDict
        sectionIndexes = newIndexes
        delegate?.didUpdateModel()
    }
}

extension SongsViewModel {
    
    private func getConcreteAlbum(identifier: String, source: AWMediaSource, completion: @escaping (AWConcreteAlbum) -> Void) {
        
        repo.getConcreteAlbum(identifier: identifier, from: source) { result in
            switch result {
            case .success(let concrete):
                completion(concrete)
            case .failure(let error):
                self.delegate?.didEncounterError(error)
            }
        }
    }
    
    private func getConcreteArtist(identifier: String, source: AWMediaSource, completion: @escaping (AWConcreteArtist) -> Void) {
        
        repo.getConcreteArtist(identifier: identifier, from: source) { result in
            switch result {
            case .success(let concrete):
                completion(concrete)
            case .failure(let error):
                self.delegate?.didEncounterError(error)
            }
        }
    }
}
