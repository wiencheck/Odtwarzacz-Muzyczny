//
//  Helpers.swift
//  Musico
//
//  Created by adam.wienconek on 13.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import MediaPlayer

extension AWPlayer {
    
    ///Notification sent when player's nowPlayingItem changes.
    ///UserInfo should contain AWTrack value
    static let trackChangedNotification = Notification.Name("trackChanged")
    
    ///Notification sent when player's playbackState changes.
    ///UserInfo should contain PlaybackState value
    static let playbackStateChangedNotification = Notification.Name("playbackStateChanged")
    
    static let nextTrackNotification = Notification.Name("nextTrack")
    static let previousTrackNotification = Notification.Name("previousTrack")
    
    ///Notification sent when player's playbackMode changes.
    ///UserInfo should contain AWPlayer.PlaybackMode value
    static let playbackModeChangedNotification = Notification.Name("playbackModeChanged")
    
    ///Notification sent when player's repeatMode changes.
    ///UserInfo should contain RepeatMode value
    static let repeatModeChangedNotification = Notification.Name("repeatModeChanged")
    
    ///Notification sent when new item is successfully added as next to queue.
    ///UserInfo should contain AWTrack value
    static let itemAddNextNotification = Notification.Name("itemAddNext")
    
    ///Notification sent when new item is successfully added as last to queue.
    ///UserInfo should contain AWTrack value
    static let itemAddLastNotification = Notification.Name("itemAddLast")
    
    ///Notification sent when player's audioRoute changes.
    ///UserInfo should contain AWPlayer.AudioOutputRoute value
    static let audioRouteChangedNotification = Notification.Name("audioRouteChanged")
    
    static let userQueueChangedNotification = Notification.Name("userQueueChanged")
    static let defaultQueueChangedNotification = Notification.Name("defaultQueueChanged")
    
    static let playerDidEncounterErrorNotification = Notification.Name("playerDidEncounterErrorNotification")
    
}
