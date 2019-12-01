//
//  SpotifyTrack.swift
//  Plum
//
//  Created by Adam Wienconek on 29.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

protocol SpotifyTrack {
    func uri() -> String
    func uid() -> String
    
    func saveToUserLibrary(completion: ((Error?) -> Void)?)
    
    func removeFromUserLibrary(completion: ((Error?) -> Void)?)
}

extension SpotifyTrack {
    func uid() -> String {
        return uri().components(separatedBy: ":").last!
    }
}

extension SimplifiedTrack: SpotifyTrack {
    func uri() -> String {
        return uri
    }
}

extension SPTPlaybackTrack: SpotifyTrack {
    func uri() -> String {
        return uri
    }
}

extension RealmTrack: SpotifyTrack {
    func uid() -> String {
        return _trackUid
    }
    
    func uri() -> String {
        return "spotify:track:" + _trackUid
    }
}

extension RealmPlaylistTrack: SpotifyTrack {
    var uid: String {
        return _trackUid
    }
    
    func uri() -> String {
        return "spotify:track:" + _trackUid
    }
}

extension AWTrack where Self: SpotifyTrack {
    func saveToUserLibrary(completion: ((Error?) -> Void)?) {
        Spartan.saveTracks(trackIds: [uid()], success: {
            RealmManager.saveTrack(self, completion: completion)
            NotificationCenter.default.post(name: SpotifyConstants.Notifications.localLibraryDidChange, object: nil)
        }, failure: completion)
    }
    
    func removeFromUserLibrary(completion: ((Error?) -> Void)?) {
        Spartan.removeSavedTracks(trackIds: [uid()], success: {
            RealmManager.removeTrack(self, completion: completion)
            NotificationCenter.default.post(name: SpotifyConstants.Notifications.localLibraryDidChange, object: nil)
        }, failure: completion)
    }
}
