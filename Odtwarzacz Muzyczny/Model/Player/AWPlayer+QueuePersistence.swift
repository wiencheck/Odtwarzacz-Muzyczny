//
//  AWPlayer+QueuePersistence.swift
//  Plum
//
//  Created by Adam Wienconek on 17.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

extension AWPlayer {
    
    internal struct PersistenceKeys {
        static let savedQueueKey = "savedQueue"
        static let savedIndexKey = "savedIndex"
        static let savedPlaybackModeKey = "savedMode"
        static let savedQueueDescriptionKey = "savedDescription"
    }
    
    /// Dumbed down version of AWTrack with only basic properties
    /// letting retrieve those items, fetch them and feed to player
    struct SavedQueueTrack: Codable {
        let trackUid: String
        let source: AWMediaSource
        let index: Int
        
        init(track: AWTrack, index: Int) {
            trackUid = track.trackUid
            source = track.source
            self.index = index
        }
    }
    
    internal func saveQueue() {
//        DispatchQueue.main.async {
//            let existingQueue = self.queue
//            let unique = existingQueue.enumerated().map { index, track in
//                return (track.trackUid,
//                        SavedQueueTrack(track: track, index: index))
//            }
//            let dictionary = Dictionary(uniqueKeysWithValues: unique)
//            do {
//                let data = try JSONEncoder().encode(dictionary)
//                UserDefaults.standard.set(data, forKey: PersistenceKeys.savedQueueKey)
//            } catch let error {
//                print(error.localizedDescription)
//            }
//        }
    }
    
    public func savedQueue() -> [String: SavedQueueTrack]? {
//        guard let data = UserDefaults.standard.data(forKey: PersistenceKeys.savedQueueKey) else {
//            return nil
//        }
//        do {
//            let decoded = try JSONDecoder().decode([String: SavedQueueTrack].self, from: data)
//            return decoded
//        } catch let error {
//            print(error.localizedDescription)
//            return nil
//        }
        return nil
    }
    
    public func restoreState(tracks: [AWTrack]) {
        let defaults = UserDefaults.standard
        let savedIndex = defaults.integer(forKey: PersistenceKeys.savedIndexKey)
        //let savedMode = ShuffleMode(rawValue:  defaults.integer(forKey: PersistenceKeys.savedPlaybackModeKey)) ?? .default
        let savedDescription = defaults.string(forKey: PersistenceKeys.savedQueueDescriptionKey)
        
        setOriginalQueue(with: tracks, description: savedDescription)
//        setShuffleMode(savedMode)
        setNowPlayingItem(at: savedIndex)
    }
    
}
