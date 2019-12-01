//
//  RealmManager.swift
//  Plum
//
//  Created by Adam Wienconek on 20.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import RealmSwift
import Spartan

class RealmManager {
    
    private init() {}
    
    var progress: Progress?
    
    private static var hiddenRealm: Realm {
        return Realm.create()
    }
    
    /// Returns collection of objects with 'shouldBeDeleted' property set to false.
    private class func getValidObjects<T: Object>() -> Results<T> {
        let predicate = NSPredicate(format: "shouldBeDeleted == %@", NSNumber(value: false))
        let objects = Realm.create().objects(T.self).filter(predicate)
        return objects
    }
    
    private class func getValidObject<T: Object>(forKey key: String) -> T? {
        guard let obj = Realm.create().object(ofType: T.self, forPrimaryKey: key),
            obj.value(forKey: "shouldBeDeleted") as? Bool == false else {
                return nil
        }
        return obj
    }
    
    class func getTrack(identifier: String) -> RealmTrack? {
        return getValidObject(forKey: identifier) as? RealmTrack
    }
    
    class func getAlbum(identifier: String) -> RealmAlbum? {
        return getValidObject(forKey: identifier) as? RealmAlbum
    }
    
    class func getArtist(identifier: String) -> RealmArtist? {
        return getValidObject(forKey: identifier) as? RealmArtist
    }
    
    class func getTracks(identifiers: [String]) -> [RealmTrack] {
        return hiddenRealm.objects(RealmTrack.self).filter { identifiers.contains($0.trackUid) }
    }
    
    class func getTracksDictionary(for source: AWMediaSource? = nil) -> [String: RealmTrack] {
        let KV = getTracks(for: source).map { ($0._trackUid, $0) }
        return Dictionary(uniqueKeysWithValues: KV)
    }
    
    class func getAlbumsDictionary(for source: AWMediaSource? = nil) -> [String: RealmAlbum] {
        let KV = getAlbums(for: source).map { ($0._albumUid, $0) }
        return Dictionary(uniqueKeysWithValues: KV)
    }
    
    class func getArtistsDictionary(for source: AWMediaSource? = nil) -> [String: RealmArtist] {
        let KV = getArtists(for: source).map { ($0._artistUid, $0) }
        return Dictionary(uniqueKeysWithValues: KV)
    }
    
    class func getPlaylistsDictionary(for source: AWMediaSource? = nil) -> [String: RealmPlaylist] {
        let KV = getPlaylists(for: source).map { ($0._playlistUid, $0) }
        return Dictionary(uniqueKeysWithValues: KV)
    }
    
    class func getTracks(for source: AWMediaSource? = nil) -> [RealmTrack] {
        guard let source = source else {
            return Array(getValidObjects() as Results<RealmTrack>)
        }
        let predicate = NSPredicate(format: "shouldBeDeleted == NO AND _source == @%", source.rawValue)
        return Array(getValidObjects().filter(predicate) as Results<RealmTrack>)
    }
    
    class func getAlbums(for source: AWMediaSource? = nil) -> [RealmAlbum] {
        guard let source = source else {
            return Array(getValidObjects() as Results<RealmAlbum>)
        }
        let predicate = NSPredicate(format: "shouldBeDeleted == NO AND _source == @%", source.rawValue)
        return Array(getValidObjects().filter(predicate) as Results<RealmAlbum>)
    }
    
    class func getArtists(for source: AWMediaSource? = nil) -> [RealmArtist] {
        guard let source = source else {
            return Array(getValidObjects() as Results<RealmArtist>)
        }
        let predicate = NSPredicate(format: "shouldBeDeleted == NO AND _source == @%", source.rawValue)
        return Array(getValidObjects().filter(predicate) as Results<RealmArtist>)
    }
    
    class func getPlaylists(for source: AWMediaSource? = nil) -> [RealmPlaylist] {
        guard let source = source else {
            return Array(getValidObjects() as Results<RealmPlaylist>)
        }
        let predicate = NSPredicate(format: "shouldBeDeleted == NO AND _source == @%", source.rawValue)
        return Array(getValidObjects().filter(predicate) as Results<RealmPlaylist>)
    }
    
    class func updateDatabase(savedAlbums: [SavedAlbum], albumTracks: [SimplifiedTrack], savedTracks: [SavedTrack], savedPlaylists: [SimplifiedPlaylist], completion: ((Error?) -> Void)?) {
        
        let realm = Realm.create()
        
        func discoverOldAlbums() -> [RealmAlbum] {
            let newIdentifiers = Set(savedAlbums.map {
                $0.album.albumUid
                } + savedTracks.map {
                    $0.track.albumUid
            })
            // Jest w starych, nie ma w nowych
            let objects = realm.objects(RealmAlbum.self)
            let oldIdentifiers = Set(objects.map {
                return $0._albumUid
            })
            let deletedIdentifiers = oldIdentifiers.subtracting(newIdentifiers)
            
            let predicate = NSPredicate(format: "_albumUid IN %@", deletedIdentifiers)
            let deletedObjects = objects.filter(predicate)
            return Array(deletedObjects)
        }
        
        func discoverOldTracks() -> [RealmTrack] {
            let newIdentifiers = Set(albumTracks.map {
                $0.trackUid
                } + savedTracks.map {
                    $0.track.trackUid
            })
            // Jest w starych, nie ma w nowych
            let objects = realm.objects(RealmTrack.self)
            let oldIdentifiers = Set(objects.map {
                return $0._trackUid
            })
            let deletedIdentifiers = oldIdentifiers.subtracting(newIdentifiers)
            
            let predicate = NSPredicate(format: "_trackUid IN %@", deletedIdentifiers)
            let deletedObjects = objects.filter(predicate)
            return Array(deletedObjects)
        }
        
        func discoverOldArtists() -> [RealmArtist] {
            let newIdentifiers = Set(savedAlbums.map {
                                $0.album.albumArtistUid
                                } + savedTracks.map {
                                    $0.track.albumArtistUid
                            })
            // Jest w starych, nie ma w nowych
            let objects = realm.objects(RealmArtist.self)
            let oldIdentifiers = Set(objects.map {
                return $0._artistUid
            })
            let deletedIdentifiers = oldIdentifiers.subtracting(newIdentifiers)
            
            let predicate = NSPredicate(format: "_artistUid IN %@", deletedIdentifiers)
            let deletedObjects = objects.filter(predicate)
            return Array(deletedObjects)
        }
        
        func discoverOldPlaylists() -> [RealmPlaylist] {
            let newIdentifiers = savedPlaylists.map {
                $0.uid
            }
            
            let old = realm.objects(RealmPlaylist.self)
            return old.filter { rlm in
                !newIdentifiers.contains(where: { rlm._playlistUid == $0 })
            }
        }
        
        print("Discovering new tracks")
        
        // Tu mam załatwione albumy z savedAlbums
        var albumsDict = [String: RealmAlbum]()
        savedAlbums.forEach { saved in
            let key = saved.album.albumUid
            if albumsDict[key] == nil {
                albumsDict.updateValue(RealmAlbum.factory(album: saved), forKey: key)
            }
            let count = albumsDict[key]?._trackCount ?? 0
            albumsDict[key]?._trackCount = count + saved.album.tracks.total
        }
        
        // Tu mam załatwione albumy z savedTracks
        savedTracks.forEach { saved in
            let key = saved.track.albumUid
            if albumsDict[key] == nil {
                albumsDict.updateValue(RealmAlbum.factory(track: saved), forKey: key)
            }
            let count = albumsDict[key]?._trackCount ?? 0
            albumsDict[key]?._trackCount = count + 1
        }
        
        // Create dictionary of artists from the 'albums' array.
        
        // Tu mam załatwione artists z savedAlbums
        var artistsDict = [String: RealmArtist]()
        savedAlbums.forEach { saved in
            let key = saved.album.albumArtistUid
            if artistsDict[key] == nil {
                artistsDict.updateValue(RealmArtist.factory(album: saved), forKey: key)
            }
            let count = artistsDict[key]?._trackCount ?? 0
            artistsDict[key]?._trackCount = count + saved.album.tracks.total
        }
        
        // Tu mam artists z savedTracks
        savedTracks.forEach { saved in
            let key = saved.track.albumArtistUid
            if artistsDict[key] == nil {
                artistsDict.updateValue(RealmArtist.factory(track: saved), forKey: key)
            }
            let count = artistsDict[key]?._trackCount ?? 0
            artistsDict[key]?._trackCount = count + 1
        }
        
        var tracksDict = [String: RealmTrack]()
        
        // Tu mam załatwione tracki z savedAlbums
        albumTracks.forEach { track in
            let key = track.trackUid
            if tracksDict[key] == nil {
                tracksDict.updateValue(RealmTrack.factory(track: track), forKey: key)
            }
        }
        
        // Tu mam załatwione tracki z saved tracks
        savedTracks.forEach { saved in
            let key = saved.track.trackUid
            if tracksDict[key] == nil {
                tracksDict.updateValue(RealmTrack.factory(track: saved), forKey: key)
            }
        }
        
        let oldTracks = discoverOldTracks()
        let oldAlbums = discoverOldAlbums()
        let oldArtists = discoverOldArtists()
        let oldPlaylists = discoverOldPlaylists()
        
        let newRealmTracks = tracksDict.values
        let newRealmAlbums = albumsDict.values
        let newRealmArtists = artistsDict.values
        let newRealmPlaylists = savedPlaylists.map { RealmPlaylist.factory(from: $0) }
        
        print("Modifying database")
        print("Tracks: \(oldTracks.count) old, \(newRealmTracks.count) new")
        print("Albums: \(oldAlbums.count) old, \(newRealmAlbums.count) new")
        print("Artists: \(oldArtists.count) old, \(newRealmArtists.count) new")
        print("Artists: \(oldPlaylists.count) old, \(newRealmPlaylists.count) new")
        
        do {
            try autoreleasepool {
                try realm.write {
                    oldTracks.forEach {
                        $0.shouldBeDeleted = true
                    }
                    oldAlbums.forEach {
                        $0.shouldBeDeleted = true
                    }
                    oldArtists.forEach {
                        $0.shouldBeDeleted = true
                    }
                    oldPlaylists.forEach {
                        $0.shouldBeDeleted = true
                    }
//                    realm.delete(oldTracks)
//                    realm.delete(oldAlbums)
//                    realm.delete(oldArtists)
//                    realm.delete(oldPlaylists)
                    
                    realm.add(newRealmTracks, update: .modified)
                    realm.add(newRealmAlbums, update: .modified)
                    realm.add(newRealmArtists, update: .modified)
                    realm.add(newRealmPlaylists, update: .modified)
                }
                
            }
            
            Realm.create().refresh()
            completion?(nil)
        } catch let error {
            completion?(error)
        }
        print("Update database finish")
        
    }
    
    class func updatePlaylist(identifier: String, tracks: [Track], completion: ((Bool, Error?) -> Void)?) {
        let realm = Realm.create()
        
        guard let storedPlaylist = realm.object(ofType: RealmPlaylist.self, forPrimaryKey: identifier) else {
            print("Nie znalazłem takiej playlisty w realmie")
            return
        }
        
        var modified = false
        
        func discoverOldTracks() -> [RealmPlaylistTrack] {
            let newIdentifiers = tracks.map { $0.uid }
            
            // Jest w starych, nie ma w nowych
            let old = storedPlaylist.tracks
            return old.filter { rlm in
                !newIdentifiers.contains(where: { rlm.trackUid == $0 })
            }
        }
        
        func discoverNewTracks() -> [RealmPlaylistTrack] {
            let new = tracks.filter { sim in
                !storedPlaylist.tracks.contains(where: { $0._trackUid == sim.uid })
            }
            var ne = [RealmPlaylistTrack]()
            for _n in new {
                if let existing = realm.object(ofType: RealmPlaylistTrack.self, forPrimaryKey: _n.trackUid) {
                    try? realm.write {
                        existing.playlists.append(storedPlaylist)
                    }
                    modified = true
                    continue
                }
                let n = RealmPlaylistTrack.factory(from: _n)
                n.playlists.append(storedPlaylist)
                ne.append(n)
            }
            return ne
//            return new.map {
//                let rlm: RealmPlaylistTrack
//                if let existing = realm.object(ofType: RealmPlaylistTrack.self, forPrimaryKey: $0.trackUid) {
//                    rlm = existing
//                } else {
//                    rlm = RealmPlaylistTrack.factory(from: $0)
//                }
//                rlm.playlists.append(storedPlaylist)
//                return rlm
//            }
        }
        
        let oldTracks = discoverOldTracks()
        let newTracks = discoverNewTracks()
        
        modified = !oldTracks.isEmpty || !newTracks.isEmpty
        
        do {
            try autoreleasepool {
                try realm.write {
                    oldTracks.forEach {
                        $0.shouldBeDeleted = true
                    }
//                    realm.delete(oldTracks)
                    realm.add(newTracks, update: .modified)
                    //storedPlaylist.tracks.append(objectsIn: newTracks)
                    //realm.add(newTracks, update: .modified)
                }
                completion?(modified, nil)
            }
        } catch let error {
            completion?(modified, error)
        }
    }
    
//    class func updateDatabase(playlists: [AWConcretePlaylist], completion: ((Error?) -> Void)?) {
//        
//        DispatchQueue.realm.async {
//            let realm = Realm.create()
//            
//            let result = realm.objects(RealmPlaylist.self)
//            
//            print("Discovering new playlists")
//            // Discover new tracks
//            let new = playlists.filter { playlist in
//                !result.contains {
//                    $0.playlistUid == playlist.playlistUid
//                }
//            }
//            
//            print("Discovering old playlists")
//            // Discover old playlists in databasa
//            let old = result.filter { playlist in
//                !playlists.contains {
//                    $0.playlistUid == playlist.playlistUid
//                }
//            }
//            
//            let realms = new.map { playlist -> RealmPlaylist in
//                let rlm = RealmPlaylist()
//                
//                rlm._source = playlist.source.rawValue
//                rlm._playlistName = playlist.playlistName
//                rlm._playlistUid = playlist.playlistUid
//                rlm._trackCount = playlist.trackCount
//                rlm._isModifiable = playlist.isModifiable
//                rlm._playlistDescription = playlist.playlistDescription
//                rlm._attributes.append(objectsIn: playlist.attributes.toString())
//                
//                let rlmTracks = playlist.items.map { track -> RealmPlaylistTrack in
//                    let r = RealmPlaylistTrack()
//                    
//                    r._source = track.source.rawValue
//                    r._playableUrl = track.playableUrl
//                    r._duration = track.duration
//                    r._trackNumber.value = track.trackNumber()
//                    r._discNumber.value = track.discNumber()
//                    
//                    r._trackName = track.trackName
//                    r._trackUid = track.trackUid
//                    
//                    r._albumName = track.albumName
//                    r._albumUid = track.albumUid
//                    
//                    r._artistName = track.artistName
//                    r._artistUid = track.artistUid
//                    
//                    r._albumArtistName = track.albumArtistName
//                    r._albumArtistUid = track.albumArtistUid
//                                        
//                    let imagesUrls = [ImageSize.large, .medium, .small].compactMap { size -> String? in
//                        return track.artworkUrl(for: size)?.absoluteString
//                    }
//                    
//                    try! realm.write {
//                        r.imagesURLs.append(objectsIn: imagesUrls)
//                    }
//                    
//                    return r
//                }
//                
//                let imagesUrls = [ImageSize.large, .medium, .small].compactMap { size -> String? in
//                    return playlist.imageUrl(for: size)?.absoluteString
//                }
//                
//                try! realm.write {
//                    rlm.tracks.append(objectsIn: rlmTracks)
//                    rlm.imagesURLs.append(objectsIn: imagesUrls)
//                }
//                
//                return rlm
//        }
//            
//        print("Modifying database")
//            do {
//                try realm.write {
//                    realm.add(realms, update: Realm.UpdatePolicy.modified)
//                    //realm.add(realms)
//                    realm.delete(old)
//                }
//                completion?(nil)
//            } catch let error {
//                completion?(error)
//            }
//        }
//    }
    class func saveTrack(_ track: AWTrack, completion: ((Error?) -> Void)?) {
        let realm = Realm.create()        
        var objects = [Object]()
        
        if realm.object(ofType: RealmTrack.self, forPrimaryKey: track.trackUid) == nil {
            objects.append(RealmTrack.factory(track: track))
        }
        
        if realm.object(ofType: RealmAlbum.self, forPrimaryKey: track.albumUid) == nil {
            //objects.append(RealmAlbum.fac)
        }
        
        if realm.object(ofType: RealmArtist.self, forPrimaryKey: track.albumArtistUid) == nil {
            //objects.append(RealmArtist.fac)
        }
        
        do {
            try autoreleasepool {
                try realm.write {
                    realm.add(objects, update: .modified)
                }
            }
            completion?(nil)
        } catch let error {
            completion?(error)
        }
    }
    
    class func removeTrack(_ track: AWTrack, completion: ((Error?) -> Void)?) {
        let realm = Realm.create()
        guard let rlm = realm.object(ofType: RealmTrack.self, forPrimaryKey: track.trackUid) else {
            let error = AWError(code: .notFound, description: "*** Could not find track in database")
            completion?(error)
            return
        }
        do {
            try autoreleasepool {
                try realm.write {
                    rlm.shouldBeDeleted = true
                }
            }
            completion?(nil)
        } catch let error {
            completion?(error)
        }
    }
    
    class func existsInDatabase(_ track: AWTrack) -> Bool {
        guard let obj = Realm.create().object(ofType: RealmTrack.self, forPrimaryKey: track.trackUid) else {
            return false
        }
        return obj.shouldBeDeleted == false
    }
    
    class func removeDeletedObjects() {
        let realm = Realm.create()
        
        let predicate = NSPredicate(format: "shouldBeDeleted == YES")
        for T in [RealmTrack.self, RealmAlbum.self, RealmArtist.self, RealmPlaylist.self, RealmPlaylistTrack.self] {
            
            let deletedObjects = realm.objects(T).filter(predicate)
            if deletedObjects.isEmpty { continue }
            
            autoreleasepool {
                try? realm.write {
                    realm.delete(deletedObjects)
                }
            }
        }
    }
    
//    class func removeAllTracks() {
//        let realm = Realm.create()
//        do {
//            try! realm.write {
//                realm.deleteAll()
//            }
//        }
//    }
    
    class func clearSpotifyDatabase() {
        let realm = Realm.create()
        try? realm.write {
            for T in [RealmTrack.self, RealmAlbum.self, RealmArtist.self, RealmPlaylist.self] {
                realm.delete(realm.objects(T))
            }
        }
    }
    
    class func compact() {
        let config = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file
            
            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneHundredMB = 100 * 1024 * 1024
            let willCompact = (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
            if willCompact {
                print("Realm will compact")
            }
            return willCompact
        })
        do {
            // Realm is compacted on the first open if the configuration block conditions were met.
            _ = try Realm(configuration: config)
        } catch let error {
            print("*** Couldn't compact Realm, with error \(error.localizedDescription)")
            // handle error compacting or opening Realm
        }
    }
    
}
