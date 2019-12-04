//
//  SongsMasterViewModel.swift
//  Musico
//
//  Created by adam.wienconek on 17.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import MediaPlayer
import UIKit

protocol PlaylistsMasterViewModelDelegate: class, Errorable, Loadable, Alertable {
    func didUpdateModel()
    func didSelectPlaylist(_ playlist: AWConcretePlaylist)
}

class PlaylistsMasterViewModel {
    
    private let repo: NewRepo
    private let player: AWPlayer
    private var sectionIndexes = [String]()
    private var itemsDictionary = [String: [AWPlaylist]]()
    private let imagesCache: NSCache<NSString, UIImage>
    
    weak var delegate: PlaylistsMasterViewModelDelegate?
    
    private var isObservingLibraryChange = false
    
    private var isGrid: Bool!
    
    init() {
        repo = AppContext.shared.newRepo
        player = AppContext.shared.player
        imagesCache = NSCache()
    }
    
    func fetchPlaylists() {
        repo.getAllPlaylists(from: [.iTunes, .spotify]) { [weak self] result in
            switch result {
            case .success(let playlists):
                self?.updateResults(with: playlists)
            case .failure(let error):
                print(error.localizedDescription)
            }
            if self?.isObservingLibraryChange == true {
                return
            }
            NotificationCenter.default.addObserver(forName: NewRepo.libraryDidUpdateNotification, object: nil, queue: nil) { notification in
                print("*** Notyfikacja że update w playlists ***")
                self?.fetchPlaylists()
            }
        }
    }
    
    private func updateResults(with newPlaylists: [AWPlaylist]) {
        let filtered = newPlaylists.filter { $0.attribute != .child }
        sortIncoming(items: filtered)
    }
    
    var numberOfSections: Int {
        return sectionIndexes.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        let key = sectionIndexes[section]
        return itemsDictionary[key]?.count ?? 0
    }
    
    private func getPlaylist(at path: IndexPath) -> AWPlaylist? {
        guard let index = sectionIndexes.at(path.section) else {
            return nil
        }
        return itemsDictionary[index]?[path.row]
    }
    
    func cellViewModel(for path: IndexPath) -> CellViewModel? {
        guard let playlist = getPlaylist(at: path) else { return nil }
        let title = playlist.playlistName
        
        let detail: String
        if playlist.attribute == .folder, let count = repo.getChildrenCount(for: playlist.playlistUid, source: playlist.source) {
            detail = "\(count) \(LocalizedStringKey.playlists.pluralForm(for: count))"
        } else {
            detail = "\(playlist.trackCount) \(LocalizedStringKey.songs.pluralForm(for: playlist.trackCount))"
        }
        
        let image = UIImage(systemName: "music.note")!
        let imageUrl = playlist.imageUrl(for: .medium)
        
        // Get source image only when item comes from other source than preferred
        //let sourceImage: UIImage? = playlist.source != Settings.primaryMediaSource ? AWAsset.overlayForSource(playlist.source) : nil
        
        return CellViewModel(title: title, detail: detail, mainImage: image, secondaryImage: nil, imageUrl: imageUrl)
    }
    
    
    
    private var preferredImageSize: ImageSize {
        // If should reduce usage or the layout is list
        if NetworkMonitor.shared.isReducingDataUsage || isGrid == false {
            return .small
        } else {
            return .medium
        }
    }
    
    func image(for path: IndexPath, completion: @escaping (AWImage) -> Void) {
        let size = preferredImageSize
        guard let playlist = getPlaylist(at: path) else { return }
        if let cachedImage = imagesCache.object(forKey: "\(playlist.playlistUid)_\(size.rawValue)" as NSString) {
            completion(AWImage(image: cachedImage, size: size))
        } else {
            guard playlist.imageUrl(for: size) == nil else { return }
            DispatchQueue.main.async {
                playlist.image(for: size, attributed: true) { image in
                    guard let image = image else {
                        completion(AWImage(image: UIImage(systemName: "music.note")!, size: .medium))
                        return
                    }
                    self.imagesCache.setObject(image, forKey: "\(playlist.playlistUid)_\(size.rawValue)" as NSString)
                    completion(AWImage(image: image, size: size))
                }
            }
        }
    }
    
    func didSelectRow(at path: IndexPath) {
        guard let playlist = getPlaylist(at: path) else { return }
        getConcretePlaylist(identifier: playlist.playlistUid, source: playlist.source) { concrete in
            concrete.image(for: .medium, attributed: false, completion: { image in
                if let image = image {
                    concrete.image = AWImage(image: image, size: .medium)
                } else {
                    concrete.image = AWImage(image: UIImage(systemName: "music.note")!, size: .medium)
                }
                self.delegate?.didSelectPlaylist(concrete)
            })
        }
    }
}

extension PlaylistsMasterViewModel {
    
    func sortIncoming(items: [AWPlaylist]) {
        print("a teraz ja")
        var newIndexes = [String]()
        var newDict = [String: [AWPlaylist]]()
        
        func insertNewSection(item: AWPlaylist, key: String) {
            newIndexes.append(key)
            newDict.updateValue([item], forKey: key)
        }
        
        func insertNewRow(item: AWPlaylist, key: String) {
            newDict[key]!.append(item)
        }
        
        for item in items {
            let key = String(item.playlistName.first ?? "?")
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
                $0.playlistName < $1.playlistName
            })
        }
        
        /// Was there a change in count
        itemsDictionary = newDict
        sectionIndexes = newIndexes
        delegate?.didUpdateModel()
    }
}

extension PlaylistsMasterViewModel {
    private func getConcretePlaylist(identifier: String, source: AWMediaSource, completion: @escaping (AWConcretePlaylist) -> Void) {
        
        delegate?.loadingDidBegin(message: LocalizedStringKey.loadingPlaylist.localized)
        repo.getConcretePlaylist(identifier: identifier, from: source) { result in
            switch result {
            case .success(let concrete):
                completion(concrete)
            case .failure(let error):
                self.delegate?.didEncounterError(error)
            }
            self.delegate?.loadingDidEnd()
        }
    }
}
