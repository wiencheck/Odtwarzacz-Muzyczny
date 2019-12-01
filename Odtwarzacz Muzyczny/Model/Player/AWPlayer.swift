//
//  AWPlayer.swift
//  Plum
//
//  Created by adam.wienconek on 08.02.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

/*
 wlaczam piosenke
 - settrack
 gra i gra
 naciskam next
 - skiptonexttrack
 gra i gra
 na dwie sekundy przed koncem blokuje next
 odpalam gapless w obecnym playerze
 */

import MediaPlayer

final class AWPlayer {
    
    enum Queue: Int {
        case `default`
        case user
    }
    
    private var players: [AWMediaSource: Player] = [:]
    private var inactivePlayers: [AWMediaSource: Player] = [:]
    
    private var gaplessTimer: Timer!
    private var shouldTrackTime = true
    private var isReducingGap = false
    
    private var interruptionObserver: Any?
    private var routeObserver: Any?
    private var sourcesObserver: Any?
    
    private(set) var currentAudioRoute: AudioOutputRoute = .default {
        didSet {
            NotificationCenter.default.post(name: AWPlayer.audioRouteChangedNotification, object: currentAudioRoute)
        }
    }
    
    private(set) var error: Error? {
        didSet {
            NotificationCenter.default.post(name: AWPlayer.playerDidEncounterErrorNotification, object: error)
        }
    }
    
    init() {
        remoteCommandCenterManager = AWRemoteControlManager(delegate: self)
        
        nowPlayingInfoManager = AWNowPlayingInfoManager(delegate: self)
        
        audioSessionHelper = AVAudioSessionHelper(delegate: self)
        
        //setCurrentAudioRoute()
    }
    
    @discardableResult
    private func getPlayer(source: AWMediaSource) -> Player {
        if let player = players[source] {
            return player
        } else if let player = inactivePlayers[source] {
            return player
        } else {
            let player: Player
            switch source {
            case .iTunes:
                player = iTunesPlayer(delegate: self)
            case .spotify:
                player = SpotifyPlayer(delegate: self)
            }
            players.updateValue(player, forKey: source)
            return player
        }
    }
    
    @discardableResult
    private func removePlayer(source: AWMediaSource) -> Player? {
        guard let p = inactivePlayers.removeValue(forKey: source) else {
            return nil
        }
        return inactivePlayers.updateValue(p, forKey: source)
    }
    
    public func setTrack(_ track: AWTrack) {
        player?.stop()
        
        player = getPlayer(source: track.source)
        player!.setTrack(track)
        nowPlayingItem = track
    }
    
    private func handleTrackDidFinish(_ successfully: Bool) {
        // If gapless, this should not be called
        guard successfully else { return }
        skipToNextTrack()
    }
    
    // MARK: Public variables
    
    private var remoteCommandCenterManager: AWRemoteControlManager!
    
    private var audioSessionHelper: AVAudioSessionHelper!
    
    private var nowPlayingInfoManager: AWNowPlayingInfoManager?
    
    /// Should now playing info show on lock screen and control center?
    public var shouldUpdateNowPlayingInfoCenter = true
    
    /// Should controls (previous, play/pause, next) show on lockscreen and in control center?
    public var shouldShowRemoteControls = true
    
    /// Currently playing item
    public var nowPlayingItem: AWTrack? {
        didSet {
            if nowPlayingItem?.trackUid == oldValue?.trackUid { return }
            NotificationCenter.default.post(name: AWPlayer.trackChangedNotification, object: nowPlayingItem, userInfo: nil)
            updateArtwork(for: nowPlayingItem)
//            }
        }
    }
    private(set)var nowPlayingInfoArtwork: MPMediaItemArtwork? {
        didSet {
            nowPlayingInfoManager?.updateNowPlayingInfo()
        }
    }
    
    public var nowPlayingQueueDescription: String? {
        didSet {
            UserDefaults.standard.set(nowPlayingQueueDescription, forKey: PersistenceKeys.savedQueueDescriptionKey)
        }
    }
    
    /// Identifier of now playing queue
    /// Example: playlist_123456789
    public var nowPlayingQueueIdentifier: QueueIdentifier?
    
    /// Shuffle or not
    private(set) var isShuffling: Bool = false {
        didSet {
            NotificationCenter.default.post(name: AWPlayer.playbackModeChangedNotification, object: isShuffling, userInfo: nil)
        }
    }
//    public var shuffleMode = ShuffleMode.default {
//        didSet {
//            NotificationCenter.default.post(name: AWPlayer.playbackModeChangedNotification, object: shuffleMode, userInfo: nil)
//            UserDefaults.standard.set(shuffleMode.rawValue, forKey: PersistenceKeys.savedPlaybackModeKey)
//        }
//    }
    
    /// Umm, repeat?
    private(set) var repeatMode = RepeatMode.none {
        didSet {
            NotificationCenter.default.post(name: AWPlayer.repeatModeChangedNotification, object: repeatMode, userInfo: nil)
        }
    }
    
    /* Set this only in delegate methods */
    private(set) var playbackState = PlaybackState.initial {
        didSet {
            NotificationCenter.default.post(name: AWPlayer.playbackStateChangedNotification, object: playbackState, userInfo: nil)
            nowPlayingInfoManager?.updateNowPlayingInfo()
            let enable = playbackState != .fetching
            remoteCommandCenterManager.enableControls(enable)
        }
    }
    
    public private(set) var indexOfNowPlayingItem: Int = 0 {
        didSet {
            UserDefaults.standard.set(indexOfNowPlayingItem, forKey: PersistenceKeys.savedIndexKey)
        }
    }
    
    /*
     Currently used object of AVAudioPlayer class
     typically you should not use it as most use cases are handled by AWWPlayer,
     however it is exposed in case you would like to access some strange properties of AVAudioPlayer
     */
//    private var player: Player? {
//        return getPlayer(source: playerSource)
//    }
    
    private var player: Player?
    
    /// "Is it playing or not?" - Apple's documentation.
    public var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    /// Duration of the asset currently associated with player.
    public var duration: TimeInterval {
        return nowPlayingItem?.duration ?? 0
    }
    
 //   private(set) var duration: TimeInterval = 0
    
    /// Current playback time in seconds.
    public var currentPlaybackTime: TimeInterval {
        return player?.currentPlaybackTime ?? 0
    }
    
//    private(set) var currentPlaybackTime: TimeInterval = 0
    
    var progress: Float {
        return Float(currentPlaybackTime / duration)
    }
    
    /// Self explanatory
    public var remainingPlaybackTime: TimeInterval {
        return duration - currentPlaybackTime
    }
    
    private var playerSource: AWMediaSource? {
        return player?.source
    }
    
    /// originalQueue is untouchable, that means that
    public private(set) var originalQueue = [AWTrack]()
    
    /// Currently playing queue, default or shuffled. You only modify it by calling setQueue() method
    public private(set) var queue = [AWTrack]()
    
    /// Items added by addNext(_:) or addLast(_:) methods land in this array. Its content will be played right after currently playing item from default queue finishes
    public private(set) var userQueue = [AWTrack]()
    
    public private(set) var userIndex = -1
    
    /// Remember to call setQueue() after calling this method
    public func setOriginalQueue(with items: [AWTrack], description: String? = nil, identifier: QueueIdentifier? = nil) {
        originalQueue = items
        nowPlayingQueueDescription = description
        nowPlayingQueueIdentifier = identifier
    }
    
    /// Clears
    public func clearQueue() {
        originalQueue.removeAll()
        queue.removeAll()
        userQueue.removeAll()
        indexOfNowPlayingItem = 0
        nowPlayingItem = nil
        NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
        NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
    }
    
    public func clearUserQueue() {
        userQueue.removeAll()
        userIndex = -1
        NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
    }
    
    /// Sets queue based on playbackMode, clears indexOfNowPlayingItem
    //    public func setQueue() {
    //        switch playbackMode {
    //        case .shuffle:
    //            queue = originalQueue.shuffled()
    //            if let item = nowPlayingItem, let index = queue.firstIndex(where: { $0.equals(item) }) {
    //                queue.swapAt(0, index)
    //            }
    //            indexOfNowPlayingItem = 0
    //        case .default:
    //            queue = originalQueue
    //            guard let item = nowPlayingItem else {
    //                return
    //            }
    //            let indexOfItem = queue.firstIndex(where: { $0.equals(item) })
    //            indexOfNowPlayingItem = indexOfItem ?? 0
    //        }
    //        // Hack to increase retain count
    //        guard queue.isEmpty == false else { return }
    //        queue.insert(queue.remove(at: 0), at: 0)
    //    }
    
    public func setQueue() {
        if isShuffling {
            queue = originalQueue.shuffled()
            if let item = nowPlayingItem, let index = queue.firstIndex(where: { $0.equals(item) }) {
                queue.swapAt(0, index)
            }
            indexOfNowPlayingItem = 0
        } else {
            queue = originalQueue
            guard let item = nowPlayingItem else {
                return
            }
            let indexOfItem = queue.firstIndex(where: { $0.equals(item) })
            indexOfNowPlayingItem = indexOfItem ?? 0
        }
//        switch shuffleMode {
//        case .shuffle:
//            queue = originalQueue.shuffled()
//            if let item = nowPlayingItem, let index = queue.firstIndex(where: { $0.equals(item) }) {
//                queue.swapAt(0, index)
//            }
//            indexOfNowPlayingItem = 0
//        case .default:
//            queue = originalQueue
//            guard let item = nowPlayingItem else {
//                return
//            }
//            let indexOfItem = queue.firstIndex(where: { $0.equals(item) })
//            indexOfNowPlayingItem = indexOfItem ?? 0
//        }
        // Hack to increase retain count
        if queue.isEmpty == false {
            queue.insert(queue.remove(at: 0), at: 0)
        }
        NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
        saveQueue()
    }
    
    private var shouldPlayFromuserQueue: Bool {
        return userIndex >= userQueue.count - 1 && !userQueue.isEmpty
    }
    
    public func skipToNextTrack() {
        let shouldResume = playbackState == .playing && isReducingGap == false
        if userIndex + 1 >= userQueue.count && !userQueue.isEmpty {
            // End of custom queue
            clearUserQueue()
            if isReducingGap {
                indexOfNowPlayingItem += 1
            } else {
                setNowPlayingItem(at: indexOfNowPlayingItem + 1)
            }
            //                setNowPlayingItem(at: indexOfNowPlayingItem + 1)
        } else if !userQueue.isEmpty {
            // Will play next custom item
            //           setCustomItemAtIndex(userIndex + 1)
            if isReducingGap {
                userIndex += 1
            } else {
                setCustomItemAtIndex(userIndex + 1)
            }
        } else {
            if indexOfNowPlayingItem + 1 >= queue.count {
                // Go back to beginning
                if isReducingGap {
                    indexOfNowPlayingItem = 0
                } else {
                    setNowPlayingItem(at: 0)
                }
                if repeatMode != .context {
                    stop()
                }
            } else {
                if isReducingGap {
                    indexOfNowPlayingItem += 1
                } else {
                    setNowPlayingItem(at: indexOfNowPlayingItem + 1)
                }
                //setNowPlayingItem(at: indexOfNowPlayingItem + 1)
            }
        }
        if shouldResume {
            play()
        }
    }
    
    public func skipToPrevious(force: Bool = false) {
        let shouldResume = playbackState == .playing
        if force == false, currentPlaybackTime > 3.0 {
            skipToBeginning()
        } else {
            if userIndex > 0 && !userQueue.isEmpty {
                setCustomItemAtIndex(userIndex - 1)
            } else if userIndex == 0 && !userQueue.isEmpty {
                userIndex = -1
                setNowPlayingItem(at: indexOfNowPlayingItem)
            } else {
                if indexOfNowPlayingItem == 0 {
                    setNowPlayingItem(at: queue.count - 1)
                } else {
                    setNowPlayingItem(at: indexOfNowPlayingItem - 1)
                }
            }
        }
        if shouldResume {
            play()
        }
    }
    
    public func skipToBeginning() {
        seek(to: 0.0)
    }
    
    /// Sets item from custom queue at given index as nowPlayingItem, if found.
    public func setCustomItemAtIndex(_ index: Int) {
        guard index < userQueue.count else {
            print("*** Given index exceeds userQueue count ***")
            return
        }
        userIndex = index
        setTrack(userQueue[userIndex])
    }
    
    /// Sets item from current queue (default or shuffled) at given index as nowPlayingItem.
    public func setNowPlayingItem(_ item: AWTrack?) {
        guard let item = item else {
            print("*** Given item was nil ***")
            return
        }
        setTrack(item)
    }
    //    public func setNowPlayingItem(_ item: AWTrack?) {
    //        guard let item = item, let index = queue.index(of: item) else {
    //            print("*** Given item was not found in the queue ***")
    //            return
    //        }
    //        setNowPlayingItem(at: index)
    //    }
    
    /*
     1. biore now item
     2. biore itemy
     3.
     */
    
    /// Sets item from current queue (default or shuffled) at given index as nowPlayingItem, if found.
    public func setNowPlayingItem(at index: Int) {
        guard index < queue.count else {
            print("*** Given index exceeds queue count ***")
            return
        }
        indexOfNowPlayingItem = index
        setTrack(queue[index])
    }
    
    public func setNowPlayingItem(_ item: AWTrack, at index: Int) {
        guard let itemIndex = queue.firstIndex(where: { $0.equals(item) }) else {
            return
        }
        queue.swapAt(index, itemIndex)
        NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
        setNowPlayingItem(at: index)
    }
    
    /// Removes next item from default or user queue.
    @discardableResult
    public func removeNext() -> AWTrack? {
        let removed: AWTrack
        if userQueue.isEmpty {
            let index = indexOfNowPlayingItem + 1
            guard queue.count > index else { return nil }
            removed = queue.remove(at: index)
            NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
        } else {
            if userIndex == userQueue.count - 1 {
                let index = indexOfNowPlayingItem + 1
                guard queue.count > index else { return nil }
                removed = queue.remove(at: index)
                NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
            } else {
                let index = userIndex + 1
                guard userQueue.count > index else { return nil }
                removed = userQueue.remove(at: index)
                NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
            }
        }
        return removed
    }
    
    /// Removes item from queue if found. Original queue stays unchanged.
    public func removeItem(_ item: AWTrack) -> AWTrack? {
        guard let indexOfItem = queue.firstIndex(where: { $0.equals(item) }) else { return nil }
        return removeItem(at: indexOfItem)
    }
    
    /// Removes item at given index from queue. Original queue stays unchanged.
    public func removeItem(at index: Int) -> AWTrack {
        let itemToRemove = queue[index]
        queue.remove(at: index)
        NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
        return itemToRemove
    }
    
    /// Removes items at given indexes from queue. Original queue stays unchanged.
    public func removeItems(at indexes: IndexSet) {
        for index in indexes.sorted(by: {$0 > $1}) {
            queue.remove(at: index)
        }
    }
    
    /// Removes item from user queue if found.
    public func removeItemFromUserQueue(_ item: AWTrack) {
        guard let indexOfItem = userQueue.firstIndex(where: { $0.equals(item) }) else { return }
        removeItemFromUserQueue(at: indexOfItem)
    }
    
    /// Removes items at given indexes from user queue. Original queue stays unchanged.
    public func removeItemsFromUserQueue(at indexes: IndexSet) {
        for index in indexes.sorted(by: {$0 > $1}) {
            userQueue.remove(at: index)
        }
        if userQueue.isEmpty {
            clearUserQueue()
        }
        NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
    }
    
    /// Removes item at given index from user queue.
    public func removeItemFromUserQueue(at index: Int) -> AWTrack {
        let removed = userQueue.remove(at: index)
        if userQueue.isEmpty {
            clearUserQueue()
        }
        NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
        return removed
    }
    
    /// Moves item in queue. Original queue stays unchanged.
    public func moveItem(at: Int, to: Int) {
        let itemToSwap = queue[at]
        queue.remove(at: at)
        queue.insert(itemToSwap, at: to)
        NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
    }
    
    /// Moves item in user queue.
    public func moveItemInUserQueue(at: Int, to: Int) {
        let itemToSwap = userQueue[at]
        userQueue.remove(at: at)
        userQueue.insert(itemToSwap, at: to)
        NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
    }
    
    /// Moves item from queue to user queue. Original queue stays unchanged.
    public func moveItemToUserQueue(at: Int, to: Int) {
        let itemToSwap = queue[at]
        queue.remove(at: at)
        userQueue.insert(itemToSwap, at: to)
        NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
    }
    
    /// Moves item from user queue to queue. Original queue stays unchanged.
    public func moveItemFromUserQueue(at: Int, to: Int) {
        let itemToSwap = userQueue[at]
        userQueue.remove(at: at)
        queue.insert(itemToSwap, at: to)
        NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
    }
    
    public func insertItem(_ item: AWTrack, to queue: Queue, at index: Int) {
        var defaultModified = false
        var userModified = false
        
        switch queue {
        case .default:
            self.queue.insert(item, at: index)
            defaultModified = true
        case .user:
            userQueue.insert(item, at: index)
            userModified = true
        }
        
        if defaultModified {
            NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
        }
        if userModified {
            NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
        }
    }
    
    @discardableResult
    public func removeItem(from queue: Queue, at index: Int) -> AWTrack? {
        var removedTrack: AWTrack?
        var defaultModified = false
        var userModified = false
        
        switch queue {
        case .default:
            removedTrack = self.queue.remove(at: index)
            defaultModified = true
        case .user:
            removedTrack = userQueue.remove(at: index)
            userModified = true
        }
        
        if defaultModified {
            NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
        }
        if userModified {
            NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
        }
        return removedTrack
    }
    
    public func removeItems(where predicate: @escaping (AWTrack) -> Bool) {
        queue.removeAll { t in
            return predicate(t) && self.nowPlayingItem?.equals(t) == false
        }
        NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
    }
    
    public func moveItem(from: (Queue, Int), to: (Queue, Int)) {
        if from == to {
            print("Nothing was changed")
            return
        } else if from.0 == .default, from.1 == indexOfNowPlayingItem {
            print("You can't move now playing item")
            return
        } else if from.0 == .user, from.1 == userIndex {
            print("You can't move now playing item")
            return
        }
        
        let movingItem: AWTrack
        var defaultModified = false
        var userModified = false
        
        
        switch from.0 {
        case .default:
            movingItem = queue.remove(at: from.1)
            defaultModified = true
        case .user:
            movingItem = userQueue.remove(at: from.1)
            userModified = true
        }
        
        // If we remove item before the new, the end index will change, only applies if the queue is the same type.
        var too = to.1
        if from.0 == to.0, from.1 < to.1 {
            //too -= 1
        }
        if from.0 == .default, from.1 < indexOfNowPlayingItem {
            indexOfNowPlayingItem -= 1
        } else if from.0 == .user, from.1 < userIndex {
            userIndex -= 1
        }
        
        if to.0 == .default, to.1 < indexOfNowPlayingItem {
            indexOfNowPlayingItem += 1
        } else if to.0 == .user, to.1 < userIndex {
            userIndex += 1
        }
        
        print(movingItem.trackName)
        print("now: \(indexOfNowPlayingItem), to: \(too)")
        
        switch to.0 {
        case .default:
            queue.insert(movingItem, at: too)
            defaultModified = true
        case .user:
            userQueue.insert(movingItem, at: too)
            userModified = true
        }
        
        if defaultModified {
            NotificationCenter.default.post(name: AWPlayer.defaultQueueChangedNotification, object: nil)
        }
        if userModified {
            NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
        }
    }
    
    // MARK: Playback
    
    /// Starts playback.
    public func play() {
        //audioSessionHelper.setSession(active: true)
        player?.play()
    }
    
    /// Pauses playback.
    public func pause() {
        player?.pause()
        //audioSessionHelper.setSession(active: false)
    }
    
    /// Stops playback
    public func stop() {
        player?.pause()
        skipToBeginning()
    }
    
    private func interrupt(reason: AudioInterruptionReason) {
        player?.interrupt(reason: reason)
    }
    
    public func seek(to time: TimeInterval) {
        player?.seekTo(time)
    }
    
    public func seek(to progress: Float) {
        let time = TimeInterval(progress) * duration
        player?.seekTo(time)
    }
    
    /// Toggles between playing and pause states.
    public func togglePlayback() {
        playbackState == .playing ? pause() : play()
    }
    
    /// Changes shuffle state and sets queue automatically.
    public func setShuffle(_ enabled: Bool) {
        isShuffling = enabled
        setQueue()
    }
    
    public func toggleShuffle() {
        setShuffle(!isShuffling)
    }
    
    public func setRepeatMode(_ mode: RepeatMode) {
        players.values.forEach({ $0.isRepeating = mode == .one })
        self.repeatMode = mode
    }
    
    /// Switch between repeat states (all / one / off)
    public func toggleRepeat() {
        let rawValue = repeatMode.rawValue < 2 ? repeatMode.rawValue + 1 : 0
        setRepeatMode(RepeatMode(rawValue: rawValue)!)
    }
    
    // MARK: Queue management (motherfucker)
    
    func addNext(_ item: AWTrack?) {
        guard let item = item else {
            return
        }
        if userQueue.isEmpty {
            userQueue.append(item)
        } else {
            userQueue.insert(item, at: userIndex + 1)
        }
        NotificationCenter.default.post(name: AWPlayer.itemAddNextNotification, object: item)
        NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
        let notification = AWNotificationManager.NotificationType.playNext(item.trackName)
        AWNotificationManager.post(notification: notification)
    }
    
    func addNext(contentsOf items: [AWTrack]?) {
        guard let items = items else {
            return
        }
        if userQueue.isEmpty {
            userQueue.append(contentsOf: items)
        } else {
            userQueue.insert(contentsOf: items, at: userIndex + 1)
        }
    }
    
    func addLast(_ item: AWTrack?) {
        guard let item = item else {
            return
        }
        userQueue.append(item)
        NotificationCenter.default.post(name: AWPlayer.itemAddLastNotification, object: item)
        NotificationCenter.default.post(name: AWPlayer.userQueueChangedNotification, object: nil)
        let notification = AWNotificationManager.NotificationType.playLast(item.trackName)
        AWNotificationManager.post(notification: notification)
    }
    
    func addLast(contentsOf items: [AWTrack]?) {
        guard let items = items else {
            return
        }
        userQueue.append(contentsOf: items)
    }
    
    // MARK: Notifications
    
//    private var shouldResumeAfterInterruption = true
//
//    private func handleAudioRouteChanged(_ notification: Notification) {
//        guard let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as? UInt else { return }
//        switch audioRouteChangeReason {
//        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
//            print("headphone plugged in")
//        case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
//            print("Route changed")
//            pause()
//        case AVAudioSession.RouteChangeReason.routeConfigurationChange.rawValue:
//            print("Route configuration Change")
//        case AVAudioSession.RouteChangeReason.categoryChange.rawValue:
//            print("Category change")
//        case AVAudioSession.RouteChangeReason.noSuitableRouteForCategory.rawValue:
//            print("No suitable Route For Category")
//        default:
//            print("Default reason")
//        }
//        setCurrentAudioRoute()
//    }
//
//    private func setCurrentAudioRoute() {
//        let session = AVAudioSession.sharedInstance()
//        if let output = session.currentRoute.outputs.first, let type = AudioOutputRouteType(rawValue: output.portType.rawValue) {
//            currentAudioRoute = AudioOutputRoute(name: output.portName, type: type)
//        } else {
//            currentAudioRoute = AudioOutputRoute.default
//        }
//    }
//
//    public var currentAudioRoute: AudioOutputRoute = AudioOutputRoute.default {
//        didSet {
//            NotificationCenter.default.post(name: AWPlayer.audioRouteChangedNotification, object: currentAudioRoute, userInfo: nil)
//        }
//    }
    
//    private func handleAudioSessionInterruption(_ notification: Notification){
//        print("Interruption received: \(notification.description)")
//        guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt, let interruptionType = AVAudioSession.InterruptionType(rawValue: typeInt) else { return }
//        switch interruptionType {
//        case .began:
//            // This interrpution keys means that interruption has ended
//            guard userInfo[AVAudioSessionInterruptionWasSuspendedKey] == nil else {
//                if playbackState == .playing {
//                    play()
//                }
//                return
//            }
//            interrupt()
//        case .ended:
//            guard let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
//            let interruptionOptions = AVAudioSession.InterruptionOptions(rawValue: optionsInt)
//            guard playbackState == .interrupted, interruptionOptions.contains(.shouldResume) else { break }
//            play()
//        }
//    }
//
//    private func setSession(active: Bool) {
//        let session = AVAudioSession.sharedInstance()
//        do {
//            try session.setCategory(.playback, mode: .default)
//            try session.setActive(active)
//        } catch let error {
//            print("*** Failed to activate audio session: \(error.localizedDescription)")
//        }
//    }
    
}

extension AWPlayer: AVAudioSessionHelperDelegate {
    func audioSession(routeChanged newRoute: AudioOutputRoute, available: Bool) {
        currentAudioRoute = newRoute
        guard available else {
            interrupt(reason: .routeChange)
            return
        }
    }
    
    func audioSessionWasInterrupted(reason: AudioInterruptionReason) {
        interrupt(reason: reason)
    }
    
    func audioSessionFinishedInterruption(shouldResume: Bool?) {
        guard shouldResume == true else { return }
        play()
    }
    
    func audioSessionShouldStayActive() -> Bool {
        switch playbackState {
        case .playing, .fetching:
            return true
        default:
            return false
        }
    }
}

// MARK: AWNowPlayingInfoTrackable methods
extension AWPlayer: MPNowPlayingInfoProvider {
    var nowPlayingInfoTitle: String? {
        return nowPlayingItem?.trackName
    }
    var nowPlayingInfoAlbumTitle: String? {
        return nowPlayingItem?.albumName
    }
    var nowPlayingInfoArtist: String? {
        return nowPlayingItem?.artistName
    }
    var nowPlayingInfoPlaybackRate: Double? {
        return playbackState == .playing ? 1 : 0
    }
    var nowPlayingInfoPlaybackDuration: TimeInterval? {
        return duration
    }
    var nowPlayingInfoCurrentPlaybackTime: TimeInterval? {
        return currentPlaybackTime
    }
    private func updateArtwork(for item: AWTrack?) {
        guard let item = item else {
            self.nowPlayingInfoArtwork = nil
            return
        }
        //nowPlayingInfoArtwork = nil
        item.artwork(for: .small) { a in
            self.nowPlayingInfoArtwork = MPMediaItemArtwork(boundsSize: MPMediaItemArtwork.preferredInfoCenterArtworkSize, requestHandler: { size -> UIImage in
                return a ?? UIImage(systemName: "music.note")!
            })
        }
    }
    var nowPlayingInfoCollectionIdentifier: String? {
        return nowPlayingQueueDescription
    }
    
    var nowPlayingInfoQueueCount: UInt? {
        if userIndex >= 0 {
            return UInt(userQueue.count)
        }
        return UInt(queue.count)
    }
    
    var nowPlayingInfoQueueIndex: UInt? {
        if userIndex >= 0 {
            return UInt(userIndex)
        }
        return UInt(indexOfNowPlayingItem)
    }
    
    var nowPlayingInfoServiceProvider: String? {
        return nowPlayingItem?.source.rawValue
    }
}

// MARK: AWRemoteControlDelegate methods
extension AWPlayer: AWRemoteControlDelegate {
    func togglePlayPauseRemoteCommand() {
        togglePlayback()
    }
    func playRemoteCommand() {
        play()
    }
    func pauseRemoteCommand() {
        pause()
    }
    func stopRemoteCommand() {
        stop()
    }
    func changePlaybackPositionRemoteCommand(position: TimeInterval) {
        seek(to: position)
    }
    func nextTrackRemoteCommand() {
        let shouldResume = playbackState == .playing
        skipToNextTrack()
        if shouldResume {
            play()
        }
    }
    func previousTrackRemoteCommand() {
        let shouldResume = playbackState == .playing
        skipToPrevious()
        if shouldResume {
            play()
        }
    }
    func changeShuffleRemoteCommand() {
        toggleShuffle()
    }
}

extension AWPlayer {
    var nextPlayingItem: AWTrack? {
        if userIndex + 1 >= userQueue.count && !userQueue.isEmpty {
            return queue.at(indexOfNowPlayingItem + 1)
        } else if !userQueue.isEmpty {
            return userQueue.at(userIndex + 1)
        } else {
            if indexOfNowPlayingItem + 1 >= queue.count {
                return repeatMode == .context ? queue.at(0) : nil
            } else {
                return queue.at(indexOfNowPlayingItem + 1)
            }
        }
    }
    
    var previousPlayingItem: AWTrack? {
        if userIndex > 0 && !userQueue.isEmpty {
            return queue.at(userIndex - 1)
        } else if userIndex == 0 && !userQueue.isEmpty {
            return queue.at(indexOfNowPlayingItem)
        } else {
            if indexOfNowPlayingItem == 0 {
                return nil
            } else {
                return queue.at(indexOfNowPlayingItem - 1)
            }
        }
    }
}

extension AWPlayer: PlayerDelegate {
    func didReceiveError(_ player: Player, error: Error, priority: ErrorPriority) {
        print("*** \(player.source) encountered error: \(error.localizedDescription)")
        self.error = error
    }
    
    func didFinishPlayingTrack(_ player: Player, successfully: Bool) {
        guard player.source == playerSource else { return }
        handleTrackDidFinish(successfully)
    }
    
    func didReceiveMessage(_ player: Player, message: String, priority: MessagePriority) {
        if priority.rawValue >= UIApplication.shared.releaseState.rawValue {
            AWNotificationManager.post(notification: .log(message))
        }
        print("\(player.source.rawValue) received message: ", message)
    }
    
    func didChangePlaybackState(_ player: Player, newState: PlaybackState) {
        guard player.source == playerSource else { return }
        playbackState = newState
    }
    
    func didChangePlaybackTime(_ player: Player, newTime: TimeInterval) {
        guard player.source == playerSource else { return }
        //nowPlayingInfoManager?.updateTime(elapsed: newTime)
    }
    
    func didRequestNextItem(_ player: Player) -> AWTrack? {
        guard let next = nextPlayingItem, next.source == player.source else { return nil }
        isReducingGap = true
        return next
    }
    
    func didStartPlayingNextItem(_ player: Player, newItem: AWTrack) {
        skipToNextTrack()
        nowPlayingItem = newItem
        isReducingGap = false
    }

}
