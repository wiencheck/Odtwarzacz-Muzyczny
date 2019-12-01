//
//  SpotifyPlayer.swift
//  Plum
//
//  Created by adam.wienconek on 08.02.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import AVFoundation

class SpotifyPlayer: NSObject, Player {
    
    var source: AWMediaSource {
        return .spotify
    }
    
    weak var delegate: PlayerDelegate?
    private(set)var nowPlayingTrack: AWTrack? {
        didSet {
            duration = nowPlayingTrack?.duration ?? 0
        }
    }
    
    private(set) var currentPlaybackTime: TimeInterval = 0 {
        didSet {
            delegate?.didChangePlaybackTime(self, newTime: currentPlaybackTime)
            if isRepeating { return }
            if duration - currentPlaybackTime > gaplessDelay {
                return
            }
            prepareForNext()
        }
    }
    
    private func prepareForNext() {
        if isReducingGap { return }
        guard let next = delegate?.didRequestNextItem(self),
            let playableUrl = next.playableUrl else { return }
        print("Spotify gapless")
        isReducingGap = true
        playbackState = .fetching
        DispatchQueue.main.async {
            self.player.queueSpotifyURI(playableUrl) { error in
                if let error = error {
                    self.playbackState = .failed
                    self.delegate?.didReceiveError(self, error: error, priority: .test)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.gaplessDelay) {
                        self.isReducingGap = false
                        self.playbackState = .playing
                        self.delegate?.didStartPlayingNextItem(self, newItem: next)
                    }
                }
            }
        }
    }
    
    private(set)var duration: TimeInterval = 0
    
    var isPlaying: Bool {
        return player.playbackState.isPlaying
    }
    
    var isRepeating: Bool = false {
        didSet {
            let mode: SPTRepeatMode = isRepeating ? .one : .off
            player.setRepeat(mode) { error in
                if let error = error {
                    self.delegate?.didReceiveError(self, error: error, priority: .user)
                    return
                }
            }
        }
    }
    
    var gaplessDelay: TimeInterval {
        return 4.4
    }
    
    private var playbackStateBeforeInterruption: PlaybackState!
    
    private(set) var error: Error?
    private(set)var playbackState: PlaybackState = .initial {
        didSet {
            delegate?.didChangePlaybackState(self, newState: playbackState)
        }
    }
    
    private var preferredBitrate: SPTBitrate {
        if NetworkMonitor.shared.isReducingDataUsage {
            return .low
        } else {
            return Settings.spotifyBitrate
        }
    }
    
    var bitrate: SPTBitrate {
        return player.targetBitrate
    }
    
    private var isReducingGap = false
    
    private let auth: SPTAuth
    private let player: SPTAudioStreamingController
    private let session: AVAudioSession
    private var sptSession: SPTSession?
        
    /// Value indicating if audio session should be deactivated on playback stop.
    private var shouldDeactivateAudioSession = false
    
    private var sessionObserver: Any?
    private var connectionObserver: Any?
    private var bitrateObserver: Any?
    
    required init(delegate: PlayerDelegate?) {
        self.delegate = delegate
        auth = .defaultInstance()
        player = .sharedInstance()
        session = .sharedInstance()
        super.init()
        addObservers()
    }
    
    deinit {
        if let observer = sessionObserver {
            NotificationCenter.default.removeObserver(observer, name: SpotifyConstants.Notifications.sessionUpdated, object: nil)
        }
        if let observer = connectionObserver {
            NotificationCenter.default.removeObserver(observer, name: NetworkMonitor.connectionChangedNotification, object: nil)
        }
        if let observer = bitrateObserver {
            NotificationCenter.default.removeObserver(observer, name: SpotifyConstants.Notifications.playerBitrateDidChange, object: nil)
        }
    }
    
    private func addObservers() {
        sessionObserver = NotificationCenter.default.addObserver(forName: SpotifyConstants.Notifications.sessionUpdated, object: nil, queue: nil) { notification in
            self.handleNewSession(notification.object as? SPTSession)
        }
        
        connectionObserver = NotificationCenter.default.addObserver(forName: NetworkMonitor.connectionChangedNotification, object: nil, queue: nil) { notification in
            let bitrate = self.preferredBitrate
            // If current bitrate is the same, return.
            if bitrate == self.bitrate { return }
            self.setBitrate(bitrate)
        }
        
        bitrateObserver = NotificationCenter.default.addObserver(forName: SpotifyConstants.Notifications.playerBitrateDidChange, object: nil, queue: nil) { notification in
            guard let bitrate = notification.object as? SPTBitrate else { return }
            self.setBitrate(bitrate)
        }
    }
    
    private func handleNewSession(_ session: SPTSession?) {
        sptSession = session
        guard let session = session else {
//            audioStreamingDidLogout(player)
//            DispatchQueue.global(qos: .utility).async {
//                self.player.logout()
//            }
            return
        }
        if player.initialized {
            print("*** player is already initialized ***")
            if player.loggedIn {
                print("*** player is already logged in ***")
                //print("*** Logging player in again ***")
                return
            }
            player.login(withAccessToken: session.accessToken)
            return
        }
        
        guard let clientID = auth.clientID else {
            let error = AWError(code: .spotifyPlayerNotAuthorized, description: "Spotify player received session, but 'clientID' was nil")
            delegate?.didReceiveError(self, error: error, priority: .test)
            closeSession()
            return
        }
        
        do {
            try player.start(withClientId: clientID, audioController: nil, allowCaching: true)
            player.delegate = self
            player.playbackDelegate = self
            let megabytes: UInt = 64
            player.diskCache = SPTDiskCache(capacity: 1024 * 1024 * megabytes)
            player.login(withAccessToken: session.accessToken)
            setBitrate(preferredBitrate)
        } catch let error {
            delegate?.didReceiveError(self, error: error, priority: .debug)
            closeSession()
        }
    }
    
    private func closeSession() {
        do {
            try player.stop()
            sptSession = nil
        } catch let error {
            delegate?.didReceiveError(self, error: error, priority: .debug)
        }
    }
    
    private func setBitrate(_ bitrate: SPTBitrate) {
        player.setTargetBitrate(bitrate) { error in
            if let error = error {
                self.delegate?.didReceiveError(self, error: error, priority: .debug)
            }
        }
    }
    
    func setTrack(_ track: AWTrack) {
        guard let playableUrl = track.playableUrl else { return }
        loadUrl(playableUrl)
    }
    
    func loadUrl(_ url: String) {
        guard player.loggedIn else {
            let error = AWError(code: .spotifyPlayerNotAuthorized)
            delegate?.didReceiveError(self, error: error, priority: .user)
            return
        }
        DispatchQueue.main.async {
//            self.player.setIsPlaying(false, callback: { stopError in
//                if let error = stopError as NSError?,
//                    error.code != SPTErrorCodeNotActiveDevice {
//                    print("*** Could not stop spotify player with error: \(error.localizedDescription)")
//                    return
//                }
//                self.player.seek(to: 0, callback: { seekError in
//                    if let error = seekError as NSError?,
//                        error.code != SPTErrorCodeNotActiveDevice {
//                        print("*** Could not stop seek player with error: \(error.localizedDescription)")
//                        return
//                    }
//                    self.player.playSpotifyURI(url, startingWith: 0, startingWithPosition: 0) { playError in
//                        if let error = playError {
//                            self.delegate?.didReceiveError(self, error: error, priority: .test)
//                            return
//                        }
//                    }
//                })
//            })
//            self.player.seek(to: 0, callback: { seekError in
//                if let error = seekError as NSError?,
//                       error.code != SPTErrorCodeNotActiveDevice {
//
//                    return
//                }
                self.player.playSpotifyURI(url, startingWith: 0, startingWithPosition: 0.1) { playError in
                    if let error = playError {
                        self.delegate?.didReceiveError(self, error: error, priority: .test)
                        return
                    }
                }
//            })
//            self.player.playSpotifyURI(url, startingWith: 0, startingWithPosition: 0) { error in
//                if let error = error {
//                    self.delegate?.didReceiveError(self, error: error, priority: .test)
//                    return
//                }
//            }
        }
    }
    
    func play() {
        guard player.loggedIn else {
            let error = AWError(code: .spotifyPlayerNotAuthorized)
            playbackState = .failed
            delegate?.didReceiveError(self, error: error, priority: .user)
            return
        }
        shouldDeactivateAudioSession = false
        setSession(active: true)
        DispatchQueue.main.async {
            self.player.setIsPlaying(true) { error in
                if let error = error {
                    self.delegate?.didReceiveError(self, error: error, priority: .user)
                } else {
                    // Success
                    self.playbackState = .playing
                }
            }
        }
    }
    
    private func resumePlayback() {
        print("*** Trying to resume playback ***")
        guard player.loggedIn, let playbackUri = nowPlayingTrack?.playableUrl else {
            let error = AWError(code: .spotifyPlayerNotAuthorized)
            playbackState = .failed
            delegate?.didReceiveError(self, error: error, priority: .user)
            return
        }
        print("*** Proceeding with resuming playback ***")
        setSession(active: true)
        DispatchQueue.main.async {
            self.player.playSpotifyURI(playbackUri, startingWith: 0, startingWithPosition: self.currentPlaybackTime) { error in
                if let error = error {
                    self.delegate?.didReceiveError(self, error: error, priority: .user)
                } else {
                    // Success
                    self.playbackState = .playing
                }
            }
        }
    }
    
    func pause() {
        guard player.loggedIn else {
            let error = AWError(code: .spotifyPlayerNotAuthorized)
            playbackState = .failed
            delegate?.didReceiveError(self, error: error, priority: .user)
            return
        }
        DispatchQueue.main.async {
            self.player.setIsPlaying(false) { error in
                if let error = error {
                    self.delegate?.didReceiveError(self, error: error, priority: .user)
                } else {
                    // Success
                    self.playbackState = .paused
                }
                self.shouldDeactivateAudioSession = true
                print("Spotify pause")
                //self.setSession(active: false)
            }
        }
    }
    
    func stop() {
        guard player.loggedIn else {
            playbackState = .failed
            let error = AWError(code: .spotifyPlayerNotAuthorized)
            delegate?.didReceiveError(self, error: error, priority: .user)
            return
        }
        DispatchQueue.main.async {
            self.player.setIsPlaying(false) { error in
                if let error = error {
                    print("*** Could not stop spotify player with error: \(error.localizedDescription)")
                } else {
                    self.playbackState = .stopped
                }
                self.shouldDeactivateAudioSession = false
                print("Spotify stop")
                //self.setSession(active: false)
            }
        }
    }
    
    func interrupt(reason: AudioInterruptionReason) {
        guard player.loggedIn else {
            playbackState = .failed
            let error = AWError(code: .spotifyPlayerNotAuthorized)
            delegate?.didReceiveError(self, error: error, priority: .user)
            return
        }
        DispatchQueue.main.async {
            self.player.setIsPlaying(false) { error in
                if let error = error {
                    print("*** Could not stop spotify player with error: \(error.localizedDescription)")
                } else {
                    self.playbackState = .interrupted
                }
                self.shouldDeactivateAudioSession = true
//                self.setSession(active: false)
            }
        }
    }
    
    func seekTo(_ time: TimeInterval) {
        guard player.loggedIn else {
            playbackState = .failed
            let error = AWError(code: .spotifyPlayerNotAuthorized)
            delegate?.didReceiveError(self, error: error, priority: .user)
            return
        }
        let seekTime = min(time, duration - gaplessDelay)
        
        DispatchQueue.main.async {
            self.player.seek(to: seekTime) { error in
                if let error = error {
                    self.delegate?.didReceiveError(self, error: error, priority: .user)
                }
            }
        }
    }
    
}

// MARK: SPTAudioStreamingDelegate methods
extension SpotifyPlayer: SPTAudioStreamingDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        delegate?.didReceiveMessage(self, message: message, priority: .test)
        print("*** Message from SPTAudioStreamingDelegate: \(message) ***")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error) {
        let nsError = error as NSError
        
        //        for err in [
        //            SPTErrorCodeFailed,
        //            SPTErrorCodeNoError,
        //            SPTErrorCodeInitFailed,
        //            SPTErrorCodeUnsupported,
        //            SPTErrorCodeNeedsPremium,
        //            SPTErrorCodeNullArgument,
        //            SPTErrorCodeUninitialized,
        //            SPTErrorCodeFailed,
        //            SPTErrorCodeBadCredentials,
        //            SPTErrorCodeInvalidArgument,
        //            SPTErrorCodeNotActiveDevice,
        //            SPTErrorCodeWrongAPIVersion,
        //            SPTErrorCodeTrackUnavailable,
        //            SPTErrorCodeApplicationBanned,
        //            SPTErrorCodeGeneralLoginError,
        //            SPTErrorCodeTravelRestriction,
        //            SPTErrorCodePlaybackRateLimited,
        //            SPTErrorCodeGeneralPlaybackError
        //            ] {
        //                if nsError.code == err {
        //                    print(err)
        //                }
        //        }
        
        print("*** Received error: (\(nsError.code))\(nsError.localizedDescription)")
        delegate?.didReceiveError(self, error: error, priority: .user)
    }
    
    func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController) {
//        shouldResumeAfterConnecting = isPlaying
        playbackStateBeforeInterruption = isPlaying ? playbackState : nil
        //playbackState = .failed
        let message = "Spotify lost connection"
        NotificationCenter.default.post(name: SpotifyConstants.Notifications.playerDisconnected, object: nil)
        delegate?.didReceiveMessage(self, message: message, priority: .test)
    }
    
    func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController) {
        if playbackStateBeforeInterruption == .playing {
            resumePlayback()
        }
        let message = "Spotify resumed connection"
        NotificationCenter.default.post(name: SpotifyConstants.Notifications.playerConnected, object: nil)
        delegate?.didReceiveMessage(self, message: message, priority: .test)
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController) {
        let message = "Spotify did encounter temporary connection problem"
        delegate?.didReceiveMessage(self, message: message, priority: .test)
    }
    
    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController) {
        let message = "Spotify did lose permission"
        delegate?.didReceiveMessage(self, message: message, priority: .test)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didSeekToPosition position: TimeInterval) {
        print("** Spotify didSeekToPosition: \(position.asString)")
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController) {
        NotificationCenter.default.post(name: SpotifyConstants.Notifications.playerLoggedStatusChanged, object: sptSession)
        delegate?.didReceiveMessage(self, message: LocalizedStringKey.spotifyLoggedInMessage.localized, priority: .user)
        print("*** SPTAudioStreamingController did log in ***")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        delegate?.didReceiveMessage(self, message: LocalizedStringKey.spotifyLoggedOutMessage.localized, priority: .user)
        print("*** SPTAudioStreamingController did log out ***")
        NotificationCenter.default.post(name: SpotifyConstants.Notifications.playerLoggedStatusChanged, object: nil)
    }
}

// MARK: SPTAudioStreamingPlaybackDelegate methods
extension SpotifyPlayer: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("is playing: \(isPlaying), shouldDeactivate: \(shouldDeactivateAudioSession)")
        if isPlaying == false, shouldDeactivateAudioSession {
            setSession(active: false)
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        guard let currentTrack = metadata.currentTrack else {
            duration = 0
            let error = AWError(code: .trackNotAvailable, description: "Selected is unavailable")
            delegate?.didReceiveError(self, error: error, priority: .user)
            delegate?.didFinishPlayingTrack(self, successfully: false)
            return
        }
        print("reducing gap spotify: \(isReducingGap)")

//        if isReducingGap {
//            nowPlayingTrack = metadata.nextTrack
//        } else {
//            nowPlayingTrack = metadata.currentTrack
//        }
        //print("metadata didChange")
//        duration = currentTrack.duration
//        if isReducingGap { return }
        nowPlayingTrack = currentTrack
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceive event: SpPlaybackEvent) {
        print("didReceivePlaybackEvent: \(event)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        //print("method: \(position.asString), prop: \(currentPlaybackTime.asString)")
        currentPlaybackTime = position
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        print("Started playing: \(trackUri)")
        //print("Source \(player.metadata.currentTrack?.playbackSourceUri ?? "unknown")")
        // If context is a single track and the uri of the actual track being played is different
        // than we can assume that relink has happended.
        let isRelinked = player.metadata.currentTrack?.playbackSourceUri.contains("spotify:track") ?? false && player.metadata.currentTrack?.playbackSourceUri != trackUri
        //print("Relinked: \(isRelinked)")
    }
    
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController) {
        print("POPO FROM QUEUE")
    }
    
    // Called when track finishes playing
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        if isRepeating || isReducingGap { return }
        delegate?.didFinishPlayingTrack(self, successfully: true)
    }
}

extension SpPlaybackEvent: CustomStringConvertible {
    public var description: String {
        switch self {
        case .SPPlaybackNotifyPlay:
            return "SPPPlaybackNotifyPlay"
        case .SPPlaybackNotifyPause:
            return "SPPPlaybackNotifyPause"
        case .SPPlaybackNotifyNext:
            return "SPPPlaybackNotifyNext"
        case .SPPlaybackNotifyPrev:
            return "SPPPlaybackNotifyPrev"
        case .SPPlaybackNotifyRepeatOn:
            return "SPPPlaybackNotifyRepeatOn"
        case .SPPlaybackNotifyRepeatOff:
            return "SPPPlaybackNotifyRepeatOff"
        case .SPPlaybackNotifyShuffleOn:
            return "SPPPlaybackNotifyShuffleOn"
        case .SPPlaybackNotifyShuffleOff:
            return "SPPPlaybackNotifyShuffleOff"
        case .SPPlaybackEventAudioFlush:
            return "SPPPlaybackNotifyAudioFlush"
        case .SPPlaybackNotifyBecameActive:
            return "SPPPlaybackNotifyBecameActive"
        case .SPPlaybackNotifyTrackChanged:
            return "SPPPlaybackNotifyTrackChanged"
        case .SPPlaybackNotifyBecameInactive:
            return "SPPPlaybackNotifyBecameInactive"
        case .SPPlaybackNotifyContextChanged:
            return "SPPPlaybackNotifyContextChanged"
        case .SPPlaybackNotifyLostPermission:
            return "SPPPlaybackNotifyLostPermission"
        case .SPPlaybackNotifyTrackDelivered:
            return "SPPPlaybackNotifyTrackDelivered"
        case .SPPlaybackNotifyMetadataChanged:
            return "SPPPlaybackNotifyMetadataChanged"
        case .SPPlaybackNotifyAudioDeliveryDone:
            return "SPPPlaybackNotifyAudioDeliveryDone"
        }
    }
}
