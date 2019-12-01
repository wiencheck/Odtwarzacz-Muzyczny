//
//  NewRepo.swift
//  Plum
//
//  Created by adam.wienconek on 16.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation
import MediaPlayer
import Spartan

class NewRepo {
    
    static var displayActivityBar = true
    
    private var providersDictionary: [AWMediaSource: MusicProviding] = [:]
    
    /// Dictionary of providers removed during this app's lifetime.
    private var inactiveProvidersDictionary: [AWMediaSource: MusicProviding] = [:]
    
    private lazy var spotlightManager = AWSpotlightManager(domainIdentifier: Bundle.main.bundleIdentifier ?? "com.adw.plum")
    
    init() {
        //addObservers()
    }
    
    @discardableResult
    private func getProvider(source: AWMediaSource) -> MusicProviding {
        if let provider = providersDictionary[source] {
            return provider
        } else if let provider = inactiveProvidersDictionary.removeValue(forKey: source) {
            providersDictionary.updateValue(provider, forKey: source)
            return provider
        } else {
            let provider: MusicProviding
            switch source {
            case .iTunes:
                provider = iTunesProvider()
            case .spotify:
                provider = SpotifyProvider()
            }
            providersDictionary.updateValue(provider, forKey: source)
            return provider
        }
    }
    
    @discardableResult
    private func removeProvider(source: AWMediaSource) -> MusicProviding? {
        guard let p = providersDictionary.removeValue(forKey: source) else {
            return nil
        }
        return inactiveProvidersDictionary.updateValue(p, forKey: source)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(forName: Settings.activeMediaSourcesChangedNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self, let sources = notification.object as? Set<AWMediaSource> else { return }
            DispatchQueue.main.async {
                for source in AWMediaSource.allCases {
                    if sources.contains(source) {
                        let p = self.getProvider(source: source)
                        p.addObservers()
                    } else {
                        let p = self.removeProvider(source: source)
                        p?.removeObservers()
                    }
                }
            }
        }
    }
    
    func f(from sources: Set<AWMediaSource>, localCompletion: ((Error?) -> Void)? = nil, remoteCompletion: ((Error?) -> Void)? = nil) {
        fetchLocalLibrary(from: sources, onProgress: nil) { localError in
            localCompletion?(localError)
            self.fetchRemoteLibrary(from: sources, onProgress: nil, completion: remoteCompletion)
        }
    }
    
    func fetchLocalLibrary(from sources: Set<AWMediaSource>, onProgress: ((AWMediaSource, Progress) -> Void)?, completion: ((Error?) -> Void)?) {
        let group = DispatchGroup()
        var error: Error?
        
        for source in sources {
            group.enter()
            getProvider(source: source).fetchLocalLibrary(onProgress: { progress in
                onProgress?(source, progress)
            }, completion: { err in
                if let err = err {
                    error = err
                } else {
                    NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: source)
                }
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion?(error)
        }
    }
    
    func fetchRemoteLibrary(from sources: Set<AWMediaSource>, onProgress: ((AWMediaSource, Progress) -> Void)?, completion: ((Error?) -> Void)?) {
        
        let group = DispatchGroup()
        var error: Error?
        
        for source in sources {
            group.enter()
            getProvider(source: source).fetchRemoteLibrary(onProgress: { progress in
                onProgress?(source, progress)
            }, completion: { err in
                if let err = err {
                    error = err
                } else {
                    NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: source)
                }
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion?(error)
        }
    }
    
    func sp(sources: Set<AWMediaSource>, types: [AWSpotlightItemType]) {
        let group = DispatchGroup()
        var error: Error?
        
        for type in types {
            group.enter()
            switch type {
            case .song:
                getAllSongs(from: sources) { result in
                    switch result {
                    case .success(let collection):
                        
                        guard let searchable = collection as? [AWSpotlightSearchable] else {
                            return
                        }
                        
                        self.spotlightManager.index(items: searchable, type: .song, queue: .main, completion: { err in
                            error = err
                            group.leave()
                        })
                    case .failure(let err):
                        error = err
                        group.leave()
                    }
                }
            case .playlist:
                getAllPlaylists(from: sources) { result in
                    switch result {
                    case .success(let playlists):
                        
                        guard let searchable = playlists as? [AWSpotlightSearchable] else {
                            return
                        }
                        
                        self.spotlightManager.index(searchable, type: .playlist, completion: { err in
                            error = err
                            group.leave()
                        })
                    case .failure(let err):
                        error = err
                        group.leave()
                    }
                }
            default:
                break
            }
        }
        
        group.notify(queue: .main) {
            print(error?.localizedDescription)
        }
    }
    
    // MARK: Songs
    
    func getSong(identifier: String, from source: AWMediaSource, completion: @escaping QueryCallback<AWTrack>) {
        providersDictionary[source]?.getTrack(identifier: identifier, completion: completion)
    }
    
    func getSongs(dict: [AWMediaSource: [String]], queue: DispatchQueue, completion: @escaping QueryCallback<AWTrackCollection>) {
        var tracks = [AWTrack]()
        let group = DispatchGroup()
        
        queue.async {
            for source in dict.keys {
                guard let identifiers = dict[source], !identifiers.isEmpty, let provider = self.providersDictionary[source] else { continue }
                group.enter()
                provider.getTracks(identifiers: identifiers, completion: { result in
                    switch result {
                    case .success(let collection):
                        tracks.append(contentsOf: collection)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    group.leave()
                })
            }
        }
        
        group.notify(queue: queue) {
            completion(.success(tracks))
        }
    }
    
    func getSongs(dict: [AWMediaSource: [String]], completion: @escaping QueryCallback<AWTrackCollection>) {
        var tracks = [AWTrack]()
        let group = DispatchGroup()
        
        for source in dict.keys {
            guard let identifiers = dict[source], !identifiers.isEmpty, let provider = providersDictionary[source] else { continue }
            group.enter()
            provider.getTracks(identifiers: identifiers, completion: { result in
                switch result {
                case .success(let collection):
                    tracks.append(contentsOf: collection)
                case .failure(let error):
                    completion(.failure(error))
                }
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion(.success(tracks))
        }
    }
    
    func getAllSongs(from sources: Set<AWMediaSource>, completion: @escaping QueryCallback<AWTrackCollection>) {
        
        var tracks = [AWTrack]()
        let group = DispatchGroup()
        
        for source in sources {
            group.enter()
            getProvider(source: source).getAllTracks { result in
                switch result {
                case .success(let collection):
                    tracks.append(contentsOf: collection)
                case .failure(let error):
                    completion(.failure(error))
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(tracks))
        }
    }
    
    // MARK: Albums
    
    func getAllAlbums(from sources: Set<AWMediaSource>, completion: @escaping QueryCallback<[AWAlbum]>) {
        
        var albums = [AWAlbum]()
        let group = DispatchGroup()
        
        for source in sources {
            
            group.enter()
            getProvider(source: source).getAllAlbums { result in
                switch result {
                case .success(let newAlbums):
                    albums.append(contentsOf: newAlbums)
                case .failure(let error):
                    completion(.failure(error))
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(albums))
        }
    }
    
    func getTracksForAlbum(identifier: String, from source: AWMediaSource, completion: @escaping QueryCallback<AWTrackCollection>) {
        
        providersDictionary[source]?.getTracksForAlbum(identifier: identifier, completion: completion)
    }
    
    func getTrackCountForAlbum(identifier: String, from source: AWMediaSource) -> Int? {
        return providersDictionary[source]?.trackCountForAlbum(identifier: identifier)
    }
    
    func getConcreteAlbum(identifier: String, from source: AWMediaSource, completion: @escaping QueryCallback<AWConcreteAlbum>) {
        let group = DispatchGroup()
        let provider = getProvider(source: source)
        
        var album: AWAlbum? {
            didSet {
                guard let album = album else { return }
                provider.getTracksForAlbum(identifier: album.albumUid) { result in
                    switch result {
                    case .success(let tracks):
                        let c = AWConcreteAlbum(album: album, tracks: tracks)
                        completion(.success(c))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        provider.getAlbum(identifier: identifier) { result in
            switch result {
            case .success(let a):
                album = a
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Artists
    
    func getAllArtists(from sources: Set<AWMediaSource>, completion: @escaping QueryCallback<[AWArtist]>) {
        
        var artists = [AWArtist]()
        let group = DispatchGroup()
        
        for source in sources {
            group.enter()
            getProvider(source: source).getAllArtists { result in
                switch result {
                case .success(let newArtists):
                    artists.append(contentsOf: newArtists)
                case .failure(let error):
                    completion(.failure(error))
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(artists))
        }
    }
    
    func getAlbumsForArtist(identifier: String, from source: AWMediaSource, completion: @escaping QueryCallback<[AWAlbum]>) {
        providersDictionary[source]?.getAlbumsForArtist(identifier: identifier, completion: completion)
    }
    
    func getTracksForArtist(identifier: String, from source: AWMediaSource, completion: @escaping QueryCallback<AWTrackCollection>) {
        providersDictionary[source]?.getTracksForArtist(identifier: identifier, completion: completion)
    }
    
    func getTrackCountForArtist(identifier: String, from source: AWMediaSource) -> Int? {
        return providersDictionary[source]?.trackCountForArtist(identifier: identifier)
    }
    
    func getConcreteArtist(identifier: String, from source: AWMediaSource, completion: @escaping QueryCallback<AWConcreteArtist>) {
        
        let provider = getProvider(source: source)
        var artist: AWArtist? {
            didSet {
                guard let artist = artist else { return }
                provider.getAlbumsForArtist(identifier: identifier) { result in
                    switch result {
                    case .success(let albums):
                        provider.getTracksForArtist(identifier: identifier) { trackResult in
                            switch trackResult {
                            case .success(let tracks):
                                let c = AWConcreteArtist(artist: artist, albums: albums, items: tracks)
                                completion(.success(c))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        
        provider.getArtist(identifier: identifier) { result in
            switch result {
            case .success(let a):
                artist = a
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Playlists
    
    func getAllPlaylists(from sources: Set<AWMediaSource>, completion: @escaping QueryCallback<[AWPlaylist]>) {
        
        var playlists = [AWPlaylist]()
        let group = DispatchGroup()
        
        for source in sources {
            group.enter()
            let provider = getProvider(source: source)
            if sources.count > 1 {
                playlists.append(provider.tracksPlaylist)
            }
            provider.getAllPlaylists { result in
                switch result {
                case .success(let newPlaylist):
                    playlists.append(contentsOf: newPlaylist)
                case .failure(let error):
                    completion(.failure(error))
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(playlists))
        }
    }
    
    func getTracksForPlaylist(identifier: String, from source: AWMediaSource, completion: @escaping QueryCallback<AWTrackCollection>) {
        let provider = getProvider(source: source)
        if identifier == provider.source.rawValue {
            DispatchQueue.main.async {
                let sorted = provider.tracks.sorted(by: { t1, t2 -> Bool in
                    return String.alphanumericsAscendingSort(t1.sortName, t2.sortName)
                })
                completion(.success(sorted))
            }
            return
        }
        provider.getTracksForPlaylist(identifier: identifier, completion: completion)
    }
    
    func getConcretePlaylist(identifier: String, from source: AWMediaSource, completion: @escaping QueryCallback<AWConcretePlaylist>) {
        
        let provider = getProvider(source: source)
        
        var playlist: AWPlaylist? {
            didSet {
                guard let p = playlist else { return }
                var concrete: AWConcretePlaylist? {
                    didSet {
                        guard let c = concrete else { return }
                        completion(.success(c))
                    }
                }
                getTracksForPlaylist(identifier: p.playlistUid, from: source) { result in
                        switch result {
                        case .success(let tracks):
                            concrete = AWConcretePlaylist(playlist: p, items: tracks)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                }
//                provider.getTracksForPlaylist(identifier: p.playlistUid) { result in
//                    switch result {
//                    case .success(let tracks):
//                        concrete = AWConcretePlaylist(playlist: p, items: tracks)
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
            }
        }
        
        if identifier == provider.source.rawValue {
            playlist = provider.tracksPlaylist
            return
        }
        provider.getPlaylist(identifier: identifier) { result in
            switch result {
            case .success(let p):
                playlist = p
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getChildrenPlaylists(for identifier: String, source: AWMediaSource, completion: @escaping QueryCallback<[AWPlaylist]>) {
        providersDictionary[source]?.getChildrenPlaylists(for: identifier, completion: completion)
    }
    
    func getChildrenCount(for identifier: String, source: AWMediaSource) -> Int? {
        return providersDictionary[source]?.getChildrenCount(for: identifier)
    }
    
    func getPlaylist(for identifier: String, source: AWMediaSource, completion: @escaping QueryCallback<AWPlaylist>) {
        providersDictionary[source]?.getPlaylist(identifier: identifier, completion: completion)
    }
        
    // MARK: Spotlight interaction
    
    public func spotlightIndex(_ elements: [AWSpotlightItemType], completion: IndexCompletion?) {
        let group = DispatchGroup()
        var error: Error?
        
        DispatchQueue.spotlight.async {
            for type in elements {
                let items: [AWSpotlightSearchable]
                switch type {
                case .song:
                    self.getAllSongs(from: Settings.activeMediaSources) { result in
                        switch result {
                        case .success(let tracks):
                            guard let searchable = tracks as? [AWSpotlightSearchable] else {
                                return
                            }
                            self.indexItems(searchable, type: .song) { error in
                                print(error)
                            }
                        case .failure(_):
                            return
                        }
                    }
                    // TODO
                //items = [] //iTunes.allTracks as! [MPMediaItem]
                case .album:
                    items = []
                case .artist:
                    items = []
                case .playlist:
                    items = []
                }
                //            group.enter()
                //            indexItems(items, type: type) { err in
                //                error = err
                //                group.leave()
                //            }
            }
        }
        
//        for type in elements {
//            let items: [AWSpotlightSearchable]
//            switch type {
//            case .song:
//                getAllSongs(from: Settings.activeMediaSources) { result in
//                    switch result {
//                    case .success(let tracks):
//                        guard let searchable = tracks as? [AWSpotlightSearchable] else {
//                            return
//                        }
//                        self.indexItems(searchable, type: .song) { error in
//                            print(error)
//                        }
//                    case .failure(_):
//                        return
//                    }
//                }
//                // TODO
//                //items = [] //iTunes.allTracks as! [MPMediaItem]
//            case .album:
//                items = []
//            case .artist:
//                items = []
//            case .playlist:
//                items = []
//            }
////            group.enter()
////            indexItems(items, type: type) { err in
////                error = err
////                group.leave()
////            }
//        }
//        group.notify(queue: .main) {
//            completion?(error)
//        }
    }
    
    public func spotlightDeindex(_ elements: [AWSpotlightItemType], completion: IndexCompletion?) {
        let group = DispatchGroup()
        var error: Error?
        for type in elements {
            group.enter()
            deindexItems(nil, type: type) { err in
                error = err
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion?(error)
        }
    }
    
    // Check whether songs count changed since last indexing
    private func shouldIndexItems(_ items: [AWSpotlightSearchable], type: AWSpotlightItemType) -> Bool {
        guard let indexed = spotlightManager.indexed[type.rawValue] else { return true }
        return indexed.count != items.count
    }
    
    private func indexItems(_ items: [AWSpotlightSearchable], type: AWSpotlightItemType, completion: ((Error?) -> Void)?) {
        guard shouldIndexItems(items, type: type) else {
            completion?(nil)
            return
        }
        spotlightManager.deindex(nil, type: type) { error in
            guard error == nil else { return }
            self.spotlightManager.index(items, type: type, onProgress: nil, completion: completion)
        }
    }
    
    private func deindexItems(_ items: [MPMediaItem]?, type: AWSpotlightItemType?, completion: ((Error?) -> Void)?) {
        //spotlightManager.deindex(items, type: type, completion: completion)
    }
    
}

extension NewRepo: MusicProvidingDelegate {
    func didReceiveError(from provider: MusicProviding, error: Error) {
        let message = AWMessage(with: error)
        AWNotificationManager.post(notification: .failure(message))
    }
}

extension NewRepo {
    static let libraryDidUpdateNotification = Notification.Name("libraryDidUpdateNotification")
    static let playlistsDidUpdateNotification = Notification.Name("playlistsDidUpdateNotification")
    static let playlistDidUpdateNotification = Notification.Name("playlistDidUpdateNotification")
}

extension DispatchQueue {
    class var repo: DispatchQueue {
        return DispatchQueue(label: "repo", qos: .utility)
    }
}
