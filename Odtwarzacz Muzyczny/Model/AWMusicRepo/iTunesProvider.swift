//
//  iTunesProvider.swift
//  Plum
//
//  Created by adam.wienconek on 07.02.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import MediaPlayer

class iTunesProvider: MusicProviding {
    
    var source: AWMediaSource {
        return .iTunes
    }
    
    weak var delegate: MusicProvidingDelegate?
    
    static let iTunesLibraryPermissionDidChangeNotification = Notification.Name("iTunesLibraryPermissionDidChangeNotification")
        
    private var isObservingAuthorizationState = false
    
    var tracks: [AWTrack] {
        return Array(tracksDictionary.values)
    }
    var albums: [AWAlbum] {
        return Array(albumsDictionary.values)
    }
    var artists: [AWArtist] {
        return Array(artistsDictionary.values)
    }
    var playlists: [AWPlaylist] {
        return Array(playlistsDictionary.values)
    }
    
    private var tracksDictionary: [MPMediaEntityPersistentID: MPMediaItem] = [:]
    private var albumsDictionary: [MPMediaEntityPersistentID: MPMediaItem] = [:]
    private var artistsDictionary: [MPMediaEntityPersistentID: MPMediaItem] = [:]
    private var playlistsDictionary: [MPMediaEntityPersistentID: MPMediaPlaylist] = [:]
    private var foldersDictionary: [MPMediaEntityPersistentID: [MPMediaPlaylist]] = [:]
    
    private var albumSongsCounter: NSCountedSet!
    private var artistSongsCounter: NSCountedSet!
    private var folderPlaylistsCounter: NSCountedSet!
    
    private var observer: Any?
    private var isObservingPermissionStatus: Bool {
        return observer != nil
    }
    
    init() {
        //addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    internal func addObservers() {
        if isObservingPermissionStatus { return }
        observer = NotificationCenter.default.addObserver(forName: iTunesManager.MediaLibraryPermissionStatusChangedNotification, object: nil, queue: nil) { notification in
            guard let authorized = notification.object as? Bool,
               authorized == true else { return }
            self.fetchLocalLibrary(onProgress: nil, completion: { error in
                if let error = error {
                    
                    return
                }
                NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.iTunes)
            })
        }
    }
    
    internal func removeObservers() {
        guard let observer = observer else { return }
        NotificationCenter.default.removeObserver(observer, name: iTunesManager.MediaLibraryPermissionStatusChangedNotification, object: nil)
        self.observer = nil
    }
    
    func fetchLocalLibrary(onProgress: ((Progress) -> Void)?, completion: ((Error?) -> Void)?) {
        
        let songsQuery = MPMediaQuery.songs().filtered
        guard let items = songsQuery.items else {
            let error = AWError(code: .notFound, description: "No local iTunes items were found")
            completion?(error)
            return
        }
        
        albumsDictionary = [:]
        artistsDictionary = [:]
        playlistsDictionary = [:]
        foldersDictionary = [:]
        
        // Songs
        let songsKV = items.map { ($0.persistentID, $0) }
        tracksDictionary = Dictionary(uniqueKeysWithValues: songsKV)
        
        artistSongsCounter = NSCountedSet()
        albumSongsCounter = NSCountedSet()
        
        // Albums, artists
        for item in items {
            
            // Update artist
            let albumArtist: MPMediaEntityPersistentID
            if item.isCompilation {
                albumArtist = .variousArtistsID
            } else {
                albumArtist = item.albumArtistPersistentID
            }
            if artistsDictionary[albumArtist] == nil {
                artistsDictionary.updateValue(item, forKey: albumArtist)
            }
            artistSongsCounter.add(albumArtist)
            
            // Update album
            if albumsDictionary[item.albumPersistentID] == nil {
                albumsDictionary.updateValue(item, forKey: item.albumPersistentID)
            }
            albumSongsCounter.add(item.albumPersistentID)
        }
        
        // Playlists
        let playlistQuery = MPMediaQuery.playlists().filtered
        guard let playlistsCollections = playlistQuery.collections as? [MPMediaPlaylist] else { return }
        
        var playlistSongsCounter = [MPMediaEntityPersistentID: Int]()
        folderPlaylistsCounter = NSCountedSet()
        
        for playlist in playlistsCollections {
            if let parent = playlist.parentPersistentID {
                if foldersDictionary[parent] == nil {
                    foldersDictionary.updateValue([playlist], forKey: parent)
                } else {
                    foldersDictionary[parent]!.append(playlist)
                }
                folderPlaylistsCounter.add(parent)
            }
            playlistsDictionary.updateValue(playlist, forKey: playlist.persistentID)
            playlistSongsCounter.updateValue(playlist.count, forKey: playlist.persistentID)
        }
        
        //NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.iTunes)
        completion?(nil)
    }
    
    func fetchRemoteLibrary(onProgress: ((Progress) -> Void)?, completion: ((Error?) -> Void)?) {
        print("iTunes does not offer any remote library, fetching local instead.")
        fetchLocalLibrary(onProgress: onProgress, completion: completion)
    }
    
    // MARK: Songs

    // MARK: Albums

    func getAlbum(identifier: String, completion: @escaping QueryCallback<AWAlbum>) {
        guard let persistentId = UInt64(identifier) else {
            let message = "Wrong identifier format"
            let error = AWError(code: .notFound, description: message)
            completion(.failure(error))
            return
        }
        let query = MPMediaQuery.songs().filtered
        let predicate = MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        guard let first = query.items!.first else {
            let message = "Could not find album with given identifier :("
            let error = AWError(code: .notFound, description: message)
            completion(.failure(error))
            return
        }
        completion(.success(first))
    }
    
    func getTracksForAlbum(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>) {
        guard let persistentId = UInt64(identifier) else {
            let message = "Wrong identifier format"
            let error = AWError(code: .other, description: message)
            completion(.failure(error))
            return
        }
        let query = MPMediaQuery.songs().filtered
        query.groupingType = .album
        let predicate = MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        if query.items!.isEmpty {
            let message = "Could not find artist with given identifier :("
            let error = AWError(code: .notFound, description: message)
            completion(.failure(error))
            return
        }
        completion(.success(query.items!))
    }
    
    func trackCountForAlbum(identifier: String) -> Int? {
        guard let persistentId = UInt64(identifier) else {
            return nil
        }
        return albumSongsCounter.count(for: persistentId)
    }
    
    // MARK: Artists

    func getAlbumsForArtist(identifier: String, completion: @escaping QueryCallback<[AWAlbum]>) {
        guard let persistentId = UInt64(identifier) else {
            let message = "Wrong identifier format"
            let error = AWError(code: .other, description: message)
            completion(.failure(error))
            return
        }
        let query = MPMediaQuery.songs().filtered
        query.groupingType = .album
        let predicate: MPMediaPropertyPredicate
        if persistentId == .variousArtistsID {
            predicate = MPMediaPropertyPredicate(value: NSNumber(booleanLiteral: true), forProperty: MPMediaItemPropertyIsCompilation, comparisonType: .equalTo)
        } else {
            predicate = MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyAlbumArtistPersistentID, comparisonType: .equalTo)
        }
        query.addFilterPredicate(predicate)
        if query.collections!.isEmpty {
            let message = "Could not find any albums for given artist :("
            let error = AWError(code: .notFound, description: message)
            completion(.failure(error))
            return
        }
        let representativeItems = query.collections!.compactMap { $0.representativeItem }
        completion(.success(representativeItems))
    }
    
    func getTracksForArtist(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>) {
        guard let persistentId = UInt64(identifier) else {
            
            return
        }
        let query = MPMediaQuery.songs().filtered
        let predicate: MPMediaPropertyPredicate
        if persistentId == .variousArtistsID {
            predicate = MPMediaPropertyPredicate(value: NSNumber(booleanLiteral: true), forProperty: MPMediaItemPropertyIsCompilation, comparisonType: .equalTo)
        } else {
            predicate = MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyAlbumArtistPersistentID, comparisonType: .equalTo)
        }
        query.addFilterPredicate(predicate)
        if query.items!.isEmpty {
            
            return
        }
        completion(.success(query.items!))
    }
    
    func trackCountForArtist(identifier: String) -> Int? {
        guard let persistentId = UInt64(identifier) else {
            return nil
        }
        return artistSongsCounter.count(for: persistentId)
    }
    
    // MARK: Playlists
    
    func getTracksForPlaylist(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>) {
        guard let playlist = playlists.first(where: { String($0.playlistUid) == identifier }) as? MPMediaPlaylist else {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        let offline = playlist.items.filter {
            $0.hasProtectedAsset == false ||
            $0.isCloudItem == false
        }
        if offline.isEmpty {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        completion(.success(offline))
    }
    
    func getChildrenPlaylists(for identifier: String, completion: @escaping QueryCallback<[AWPlaylist]>) {
        guard let persistentID = UInt64(identifier),
            let children = foldersDictionary[persistentID] else {
                let error = AWError(code: AWError.Code.notFound)
                completion(.failure(error))
                return
        }
        completion(.success(children))
    }
    
    func getChildrenCount(for identifier: String) -> Int? {
        guard let persistentID = UInt64(identifier) else {
            return nil
        }
        return folderPlaylistsCounter.count(for: persistentID)
    }
    
}

enum iTunesManager {
    static var permissionChangedHandler: ((Bool) -> Void)?
    
    static func requestPermission() {
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            MPMediaLibrary.requestAuthorization { status in
                let success = status == .authorized
                NotificationCenter.default.post(name: iTunesManager.MediaLibraryPermissionStatusChangedNotification, object: success)
                permissionChangedHandler?(success)
            }
            return
        }
        NotificationCenter.default.post(name: iTunesManager.MediaLibraryPermissionStatusChangedNotification, object: true)
        permissionChangedHandler?(true)
    }
    
    static let MediaLibraryPermissionStatusChangedNotification = Notification.Name("MediaLibraryPermissionStatusChangedNotification")
}

fileprivate extension MPMediaQuery {
    /// Returns filtered query, without cloud and Apple Music content.
    var filtered: MPMediaQuery {
        // iCloud filter
        let cloudPredicate = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem, comparisonType: .equalTo)
        self.addFilterPredicate(cloudPredicate)
        
        // Apple music filter
        let drmPredicate = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyHasProtectedAsset, comparisonType: .equalTo)
        self.addFilterPredicate(drmPredicate)
        return self
    }
}

extension MPMediaEntityPersistentID {
    static let variousArtistsID: UInt64 = 1
}
