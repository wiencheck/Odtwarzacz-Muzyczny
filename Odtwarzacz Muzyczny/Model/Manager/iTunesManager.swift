//
//  iTunesManager.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 02/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import MediaPlayer

final class iTunesManager: SourceManager {
    
    static let shared = iTunesManager()
    
    var onLoggedInStatusChange: ((Bool) -> Void)?
    
    var isLoggedIn: Bool {
        return MPMediaLibrary.authorizationStatus() == .authorized
    }
    
    func logIn() {
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            MPMediaLibrary.requestAuthorization { status in
                let success = status == .authorized
                NotificationCenter.default.post(name: iTunesManager.MediaLibraryPermissionStatusChangedNotification, object: success)
                self.onLoggedInStatusChange?(success)
            }
            return
        }
        NotificationCenter.default.post(name: iTunesManager.MediaLibraryPermissionStatusChangedNotification, object: true)
        onLoggedInStatusChange?(true)
    }
    
    static let MediaLibraryPermissionStatusChangedNotification = Notification.Name("MediaLibraryPermissionStatusChangedNotification")
}
