//
//  MusicProviding.swift
//  Plum
//
//  Created by adam.wienconek on 22.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}

typealias QueryCallback<T> = ((Result<T>) -> Void)

protocol MusicProvidingDelegate: class {
    func didReceiveError(from provider: MusicProviding, error: Error)
}

protocol MusicProviding: class {
    
    var source: AWMediaSource { get }
        
    var tracks: [AWTrack] { get }
    
    var albums: [AWAlbum] { get }
    
    var artists: [AWArtist] { get }
    
    var playlists: [AWPlaylist] { get }
    
    var delegate: MusicProvidingDelegate? { get set }
    
    func fetchLocalLibrary(onProgress: ((Progress) -> Void)?, completion: ((Error?) -> Void)?)
    
    func fetchRemoteLibrary(onProgress: ((Progress) -> Void)?, completion: ((Error?) -> Void)?)
    
    // MARK: Songs
        
    func getTrack(identifier: String, completion: @escaping QueryCallback<AWTrack>)
    
    func getTracks(identifiers: [String], queue: DispatchQueue, completion: @escaping QueryCallback<AWTrackCollection>)
    
    func getTracks(identifiers: [String], completion: @escaping QueryCallback<AWTrackCollection>)
    
    func getAllTracks(completion: @escaping QueryCallback<AWTrackCollection>)
    
    // MARK: Albums
    
    func getAlbum(identifier: String, completion: @escaping QueryCallback<AWAlbum>)
        
    func getAllAlbums(completion: @escaping QueryCallback<[AWAlbum]>)
    
    func getTracksForAlbum(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>)
        
    func trackCountForAlbum(identifier: String) -> Int?
    
    // MARK: Artists
    
    func getArtist(identifier: String, completion: @escaping QueryCallback<AWArtist>)
    
    func getAllArtists(completion: @escaping QueryCallback<[AWArtist]>)
    
    func getAlbumsForArtist(identifier: String, completion: @escaping QueryCallback<[AWAlbum]>)
    
    func getTracksForArtist(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>)
    
    func trackCountForArtist(identifier: String) -> Int?
    
    // MARK: Playlists
    
    /// Playlist containing all tracks from MusicProviding object
    var tracksPlaylist: AWPlaylist { get }
    
    func getAllPlaylists(completion: @escaping QueryCallback<[AWPlaylist]>)
    
    func getPlaylist(identifier: String, completion: @escaping QueryCallback<AWPlaylist>)
    
    func getChildrenPlaylists(for identifier: String, completion: @escaping QueryCallback<[AWPlaylist]>)
    
    func getChildrenCount(for identifier: String) -> Int?
    
    func getTracksForPlaylist(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>)
    
    func addObservers()
    
    func removeObservers()
}

extension MusicProviding {
    func fetchLocalLibrary(onProgress: ((Progress) -> Void)?, completion: ((Error?) -> Void)?) {}
    
    func fetchRemoteLibrary(onProgress: ((Progress) -> Void)?, completion: ((Error?) -> Void)?) {}
    
    // MARK: Songs default implementations
    
    func getTrack(identifier: String, completion: @escaping QueryCallback<AWTrack>) {
        guard let first = tracks.first(where: { $0.trackUid == identifier }) else {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        completion(.success(first))
    }
    
    func getTracks(identifiers: [String], queue: DispatchQueue, completion: @escaping QueryCallback<AWTrackCollection>) {
        let filtered = tracks.filter { track in
            identifiers.contains(where: { uid in
                track.trackUid == uid
            })
        }
        if filtered.isEmpty {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        completion(.success(filtered))
    }
    
    func getTracks(identifiers: [String], completion: @escaping QueryCallback<AWTrackCollection>) {
        let filtered = tracks.filter { track in
            identifiers.contains(where: { uid in
                track.trackUid == uid
            })
        }
        if filtered.isEmpty {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        completion(.success(filtered))
    }

    func getAllTracks(completion: @escaping QueryCallback<AWTrackCollection>) {
        if tracks.isEmpty {
            print(self, " tracks are empty, but no error was thrown, they are just empty.")
//            let error = AWError(code: .notFound)
//            completion(.failure(error))
//            return
        }
        completion(.success(tracks))
    }

    // MARK: Albums default implementations
    
    func getAlbum(identifier: String, completion: @escaping QueryCallback<AWAlbum>) {
        guard let first = albums.first(where: { $0.albumUid == identifier }) else {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        completion(.success(first))
    }
    
    func getAllAlbums(completion: @escaping QueryCallback<[AWAlbum]>) {
        if albums.isEmpty {
            print(self, " albums are empty, but no error was thrown, they are just empty.")
//            let error = AWError(code: .notFound)
//            completion(.failure(error))
//            return
        }
        completion(.success(albums))
    }
    
    func getTracksForAlbum(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>) {
        let filtered = tracks.filter { $0.albumUid == identifier }
        if filtered.isEmpty {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        let sorted = filtered.sorted {
            guard let d0 = $0.discNumber(),
                let t0 = $0.trackNumber(),
                let d1 = $1.discNumber(),
                let t1 = $1.trackNumber() else { return false }
            return d0 == d1 ? t0 < t1 : d0 < d1 }
        completion(.success(sorted))
    }
    
    // MARK: Artists
    
    func getArtist(identifier: String, completion: @escaping QueryCallback<AWArtist>) {
        guard let first = artists.first(where: { $0.albumArtistUid == identifier }) else {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        completion(.success(first))
    }
    
    func getAllArtists(completion: @escaping QueryCallback<[AWArtist]>) {
        if artists.isEmpty {
            print(self, " artists are empty, but no error was thrown, they are just empty.")
//            let error = AWError(code: .notFound)
//            completion(.failure(error))
//            return
        }
        completion(.success(artists))
    }
    
    func getAlbumsForArtist(identifier: String, completion: @escaping QueryCallback<[AWAlbum]>) {
        let filtered = albums.filter { $0.albumArtistUid == identifier }
        if filtered.isEmpty {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        completion(.success(filtered))
    }
    
    func getTracksForArtist(identifier: String, completion: @escaping QueryCallback<AWTrackCollection>) {
        let filtered = tracks.filter { $0.albumArtistUid == identifier }
        if filtered.isEmpty {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        let sorted = filtered.sorted {
            return $0.sortName < $1.sortName
        }
        completion(.success(sorted))
    }
    
    func getTrackCountForArtist(identifier: String, completion: @escaping ((Int?) -> Void)) {
        let filtered = tracks.filter { $0.albumArtistUid == identifier }
        completion(filtered.isEmpty ? nil : filtered.count)
    }
    
    // MARK: Playlists
    
    var tracksPlaylist: AWPlaylist {
        return AWSourcePlaylist(source: source, trackCount: tracks.count)
    }
    
    func getAllPlaylists(completion: @escaping QueryCallback<[AWPlaylist]>) {
        if playlists.isEmpty {
            print(self, " playlists are empty, but no error was thrown, they are just empty.")
//            let error = AWError(code: .notFound)
//            completion(.failure(error))
//            return
        }
        completion(.success(playlists))
    }
    
    func getPlaylist(identifier: String, completion: @escaping QueryCallback<AWPlaylist>) {
        guard let first = playlists.first(where: { $0.playlistUid == identifier }) else {
            let error = AWError(code: .notFound)
            completion(.failure(error))
            return
        }
        completion(.success(first))
    }
    
    func getChildrenPlaylists(for identifier: String, completion: @escaping QueryCallback<[AWPlaylist]>) {
        print("'getChildrenPlaylists' not implemented")
    }
    
    func getChildrenCount(for identifier: String) -> Int? {
        print("'getChildrenCount' not implemented")
        return nil
    }
    
    func addObservers() {
        print("'addObservers' not implemented")
    }
    
    func removeObservers() {
        print("'removeObservers' not implemented")
    }
    
    func beginLoading() {
        AWNotificationManager.beginLoading()
    }
    
    func finishLoading(error: Error? = nil) {
        AWNotificationManager.endLoading(error: error)
    }

}
