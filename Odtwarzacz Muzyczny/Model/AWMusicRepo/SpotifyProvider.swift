//
//  SpotifyProvider.swift
//  Plum
//
//  Created by adam.wienconek on 22.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

class SpotifyProvider: MusicProviding {
    
    var source: AWMediaSource {
        return .spotify
    }
    
    weak var delegate: MusicProvidingDelegate?
    
    /// Limit for downloading
    static private let limit = 50
    
    static private var market: CountryCode? {
        if let region = Locale.current.regionCode {
            return CountryCode(rawValue: region)
        }
        return nil
    }
    
    var tracks: [AWTrack] {
        return shouldHideLibrary ? [] : Array(tracksDict.values)
    }
    var albums: [AWAlbum] {
        return shouldHideLibrary ? [] : Array(albumsDict.values)
    }
    var artists: [AWArtist] {
        return shouldHideLibrary ? [] : Array(artistsDict.values)
    }
    var playlists: [AWPlaylist] {
        return shouldHideLibrary ? [] : Array(playlistsDict.values)
    }
    
    private var tracksDict: [String: RealmTrack] = [:]
    private var albumsDict: [String: RealmAlbum] = [:]
    private var artistsDict: [String: RealmArtist] = [:]
    private var playlistsDict: [String: RealmPlaylist] = [:]
    
    private var updatedPlaylistsIds = Set<String>()
    
    /// Czy już w tym działaniu apki pobierał z neta, bo jak tak to chuj niech już nie robi
    var didFetchAlready = false
    private var isObservingLoggedState: Bool {
        return observer != nil
    }
    private var observer: Any?
    private var shouldHideLibrary = false
    private var isFetching = false
//
//    var onTracksUpdate: QueryCallback<AWTrackCollection>?
//    var onAlbumsUpdate: QueryCallback<[AWAlbum]>?
//    var onArtistsUpdate: QueryCallback<[AWArtist]>?
//    var onPlaylistsUpdate: QueryCallback<[AWPlaylist]>?
//
//    var onTracksDidLoad: (() -> Void)?
//    var onAlbumsDidLoad: QueryCallback<[AWAlbum]>?
//    var onArtistsDidLoad: QueryCallback<[AWArtist]>?
//    var onPlaylistsDidLoad: QueryCallback<[AWPlaylist]>?
    
    lazy var onErrorReceived: ((Error?) -> Void) = { error in
        guard let error = error else { return }
        self.delegate?.didReceiveError(from: self, error: error)
    }
    
    init() {
        Spartan.loggingEnabled = true
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    internal func addObservers() {
        if isObservingLoggedState { return }
        observer = NotificationCenter.default.addObserver(forName: SpotifyConstants.Notifications.playerLoggedStatusChanged, object: nil, queue: nil) { sender in
            
            if sender.object == nil  {
                self.shouldHideLibrary = true
                NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.spotify)
                return
            }
            
            self.shouldHideLibrary = false
            self.fetchLocalLibrary(onProgress: nil, completion: { _ in
                if self.didFetchAlready == false {
                    self.fetchLocalLibrary(onProgress: nil, completion: { _ in
                        NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.spotify)
                        self.fetchRemoteLibrary(onProgress: nil, completion: { _ in
                            NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.spotify)
                        })
                    })
                } else {
                    NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.spotify)
                }
            })
        }
    }
    
//    internal func addObservers() {
//        if isObservingLoggedState { return }
//        observer = NotificationCenter.default.addObserver(forName: SpotifyConstants.Notifications.sessionUpdated, object: nil, queue: .main) { sender in
//
//            if sender.object == nil  {
//                self.shouldHideLibrary = true
//                NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.spotify)
//                return
//            }
//
//            self.shouldHideLibrary = false
//            self.fetchLocalLibrary(onProgress: nil, completion: { _ in
//                if self.didFetchAlready == false {
//                    self.fetchLocalLibrary(onProgress: nil, completion: { _ in
//                        NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.spotify)
//                        self.fetchRemoteLibrary(onProgress: nil, completion: { _ in
//                            NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.spotify)
//                        })
//                    })
//                } else {
//                    NotificationCenter.default.post(name: NewRepo.libraryDidUpdateNotification, object: AWMediaSource.spotify)
//                }
//            })
//        }
//    }
    
    internal func removeObservers() {
        guard let observer = observer else { return }
        NotificationCenter.default.removeObserver(observer, name: SpotifyConstants.Notifications.playerLoggedStatusChanged, object: nil)
        self.observer = nil
    }
    
    // Na koniec te rzeczy wsadzam do realma.
    private lazy var incomingTracks: [SimplifiedTrack] = []
    private lazy var incomingAlbums: [SavedAlbum] = []
    private lazy var incomingSavedTracks: [SavedTrack] = []
    private lazy var incomingPlaylists: [SimplifiedPlaylist] = []
    
    private func nowyFetchAlbums(completion: @escaping (Error?) -> Void) {
        // Dodaj albumy i tracks
        
        var _tracks = [SimplifiedTrack]()
        func handleReceivedTracksPage(_ page: PagingObject<SimplifiedTrack>, album: SavedAlbum, _completion: ((Error?) -> Void)?) {
            
            // Zbieram SimplifiedTracks.
            let newTracks = page.items!
            
            // Przypisz album do każdego tracka.
//            newTracks =
//            newTracks.forEach { track in
//                track.album = album.album
//                track.addedAt = album.addedAt
//            }
            // Wsadzam do tablicy.
            _tracks.append(contentsOf: newTracks.map {
                $0.album = album.album
                $0.addedAt = album.addedAt
                return $0
            })
            
            if page.canMakeNextRequest {
                page.getNext(success: { nextPage in
                    handleReceivedTracksPage(nextPage, album: album, _completion: _completion)
                }) { nextError in
                    _completion?(nextError)
                }
            } else {
                // Finished getting tracks for the album
                self.incomingTracks = _tracks
                _completion?(nil)
            }
        }
        
        var _albums = [SavedAlbum]()
        func handleReceivedAlbumsPage(_ page: PagingObject<SavedAlbum>, _completion: @escaping (Error?) -> Void) {
            
            // Zbieram zapisane albumy
            let newAlbums = page.items!
            // Wyciągam zwykłe albumy
            // Wsadzam do tablicy
            _albums.append(contentsOf: newAlbums)
            
            let group = DispatchGroup()
            var error: Error?
            
            // Dla każdego albumu zbieram tracks i wsadzam do incoming.
            for album in newAlbums {
                group.enter()
                handleReceivedTracksPage(album.album.tracks, album: album) { err in
                    error = err
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                if page.canMakeNextRequest {
                    page.getNext(success: { nextPage in
                        handleReceivedAlbumsPage(nextPage, _completion: _completion)
                    }, failure: { nextError in
                        _completion(nextError)
                    })
                } else {
                    // Finished getting all saved albums
                    self.incomingAlbums = _albums
                    _completion(error)
                }
            }
        }
        
        Spartan.getSavedAlbums(limit: SpotifyProvider.limit, market: SpotifyProvider.market, success: { page in
            handleReceivedAlbumsPage(page, _completion: completion)
        }, failure: completion)
    }
    
    private func nowyFetchTracks(completion: @escaping (Error?) -> Void) {
        // Sprawdz czy track istnieje po albumach jak nie to dodaj
        
        var _tracks = [SavedTrack]()
        func handleReceivedTracksPage(_ page: PagingObject<SavedTrack>, _completion: @escaping (Error?) -> Void) {
            
            _tracks.append(contentsOf: page.items)
            
            if page.canMakeNextRequest {
                page.getNext(success: { nextPage in
                    handleReceivedTracksPage(nextPage, _completion: _completion)
                }, failure: _completion)
            } else {
                // Finished getting all tracks
                DispatchQueue.global(qos: .utility).async {
                    self.incomingSavedTracks = _tracks.filter { track in
                        if track.track.isPlayable == false {
                            return false
                        }
                        return true
                    }
                    completion(nil)
                }
            }
        }
        
        Spartan.getSavedTracks(limit: SpotifyProvider.limit, market: SpotifyProvider.market, success: { page in
            handleReceivedTracksPage(page, _completion: completion)
        }, failure: completion)
    }
    
    private func nowyFetchPlaylists(completion: @escaping (Error?) -> Void) {
        
        var _playlists = [SimplifiedPlaylist]()
        func handleReceivedPlaylistsPage(_ page: PagingObject<SimplifiedPlaylist>, _completion: ((Error?) -> Void)?) {
            
            _playlists.append(contentsOf: page.items!)
            
            if page.canMakeNextRequest {
                page.getNext(success: { nextPage in
                    handleReceivedPlaylistsPage(nextPage, _completion: _completion)
                }) { nextError in
                    _completion?(nextError)
                }
            } else {
                // When all playlists are loaded
                self.incomingPlaylists = _playlists
                _completion?(nil)
            }
            
        }
        
        Spartan.getMyPlaylists(limit: SpotifyProvider.limit, success: { page in
            handleReceivedPlaylistsPage(page, _completion: completion)
        }, failure: completion)
    }
    
    func fetchLocalLibrary(onProgress: ((Progress) -> Void)?, completion: ((Error?) -> Void)?) {
        guard SpotifyManager.shared.isLoggedIn else {
            shouldHideLibrary = true
            let error = AWError(code: .spotifyNotAuthorized)
            completion?(error)
            return
        }
        shouldHideLibrary = false
        
        tracksDict = RealmManager.getTracksDictionary()
        albumsDict = RealmManager.getAlbumsDictionary()
        artistsDict = RealmManager.getArtistsDictionary()
        playlistsDict = RealmManager.getPlaylistsDictionary()
        
        if tracksDict.isEmpty && playlistsDict.isEmpty {
            let error = AWError(code: .notFound, description: "No local Spotify items were found")
            completion?(error)
        } else {
            completion?(nil)
        }
    }
    
    func fetchRemoteLibrary(onProgress: ((Progress) -> Void)?, completion: ((Error?) -> Void)?) {
        
        if isFetching { return }
        isFetching = true
        
        guard SpotifyManager.shared.isLoggedIn else {
            shouldHideLibrary = true
            let error = AWError(code: .spotifyNotAuthorized)
            completion?(error)
            return
        }
        shouldHideLibrary = false
        
        beginLoading()
        let group = DispatchGroup()
        var error: Error?
        
        for foo in [self.nowyFetchAlbums, self.nowyFetchTracks, self.nowyFetchPlaylists] {
            group.enter()
            foo { err in
                error = err
                group.leave()
                print("Group leave")
            }
        }
        
        group.notify(queue: .realm) {
            print("Group notify")
            if let error = error {
                self.isFetching = false
                self.finishLoading(error: error)
                completion?(error)
                return
            }
            
            // Update realm
            let realmGroup = DispatchGroup()
            
            var realmError: Error?
            
            realmGroup.enter()
            RealmManager.updateDatabase(savedAlbums: self.incomingAlbums,
                                        albumTracks: self.incomingTracks,
                                        savedTracks: self.incomingSavedTracks,
                                        savedPlaylists: self.incomingPlaylists) { err in
                                            realmError = err
                                            realmGroup.leave()
            }
            
            realmGroup.notify(queue: .main, execute: {
                if let realmError = realmError {
                    self.isFetching = false
                    self.finishLoading(error: realmError)
                    completion?(realmError)
                    return
                }
                self.isFetching = false
                self.didFetchAlready = true
                self.finishLoading()
                self.fetchLocalLibrary(onProgress: nil, completion: completion)
            })
        }
    }
    // MARK: Delegate methods
    
    func getTracksForPlaylist(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>) {
        
        guard let playlist = playlistsDict[identifier] else {
            
            return
        }
        
        var comp: QueryCallback<AWTrackCollection>? = completion
        
        let savedTracks = playlist.validTracks()
        if savedTracks.isEmpty == false {
            completion(.success(savedTracks))
            comp = nil
            
            if updatedPlaylistsIds.contains(identifier) {
                return
            }
        }
        
        updatedPlaylistsIds.insert(identifier)
        var _tracks = [Track]()
        func handleNewPlaylistTracksPage(_ page: PagingObject<PlaylistTrack>) {
            let newTracks = page.items.compactMap { $0.track }
            
            _tracks.append(contentsOf: newTracks)
            
            if page.canMakeNextRequest {
                page.getNext(success: { nextPage in
                    handleNewPlaylistTracksPage(nextPage)
                }, failure: { nextError in
                    comp?(.failure(nextError))
                })
            } else {
                // When all pages are loaded
                if _tracks.isEmpty {
                    self.finishLoading()
                    let error = AWError(code: .notFound)
                    completion(.failure(error))
                    return
                }
                let availableTracks = _tracks.filter {
                    return $0.isPlayable == true
                }
                if availableTracks.isEmpty {
                    self.finishLoading()
                    let error = AWError(code: .notFound, description: "Received tracks are not available to play")
                    completion(.failure(error))
                    return
                }
                comp?(.success(availableTracks))
                DispatchQueue.realm.async {
                    RealmManager.updatePlaylist(identifier: identifier, tracks: availableTracks) { modified, error in
                        self.finishLoading(error: error)
                        if let error = error {
                            print("*** Could not update playlist \(playlist.playlistName): \(error.localizedDescription)")
                            return
                        }
                        if modified {
                            //NotificationCenter.default.post(name: NewRepo.playlistDidUpdateNotification, object: identifier)
                        }
                    }
                }
            }
        }
        
        guard let user = playlist.user else {
            let error = AWError(code: .other, description: "*** Could not get details for given playlist")
            completion(.failure(error))
            return
        }
        
        beginLoading()
        Spartan.getPlaylistTracks(userId: user, playlistId: identifier, limit: SpotifyProvider.limit, market: SpotifyProvider.market, success: { page in
            handleNewPlaylistTracksPage(page)
        }) { error in
            completion(.failure(error))
        }
    }
    
    func trackCountForAlbum(identifier: String) -> Int? {
        return albumsDict[identifier]?._trackCount
    }
    
    func trackCountForArtist(identifier: String) -> Int? {
        return artistsDict[identifier]?._trackCount
    }
    
}
