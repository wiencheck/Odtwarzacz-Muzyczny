//
//  iTunesPlayer.swift
//  Plum
//
//  Created by adam.wienconek on 08.02.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import MediaPlayer

class iTunesPlayer: NSObject, Player {
    
    var source: AWMediaSource {
        return .iTunes
    }
    
    weak var delegate: PlayerDelegate?
    private(set)var nowPlayingTrack: AWTrack?
    
    private var player: AVAudioPlayer! {
        didSet {
            player?.delegate = self
            player?.isRepeating = isRepeating
        }
    }
    
    private var nowPlayingItem: MPMediaItem? {
        didSet {
            if oldValue?.persistentID == nowPlayingItem?.persistentID { return }
            nowPlayingTrack = nowPlayingItem
            duration = nowPlayingItem?.playbackDuration ?? 0
        }
    }
    
    private(set)var currentPlaybackTime: TimeInterval = 0 {
        didSet {
            //print(currentPlaybackTime.asString, isPlaying)
            delegate?.didChangePlaybackTime(self, newTime: currentPlaybackTime)
            if isRepeating { return }
            if player.duration - player.currentTime > gaplessDelay {
                return
            }
            prepareForNext()
        }
    }
    
    private(set)var duration: TimeInterval = 0
    
    var playbackRate: Float {
        return player.rate
    }
    
    var gaplessDelay: TimeInterval {
        return 1.7
    }
    
    private(set) var error: Error?
    private(set) var playbackState: PlaybackState = .initial {
        didSet {
            setTimer(playbackState.isPlayingState)
            delegate?.didChangePlaybackState(self, newState: playbackState)
        }
    }
    
//    var isPlaying: Bool {
//        return player.isPlaying
//    }
    
    var isRepeating: Bool = false {
        didSet {
            player.isRepeating = isRepeating
        }
    }
    
    private var isReducingGap = false
    
    private let timerInterval: TimeInterval = 0.2
    private var timer: Timer!
    
    required init(delegate: PlayerDelegate?) {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "initPlum", ofType: "m4a")!)
        do {
            try player = AVAudioPlayer(contentsOf: url)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        self.delegate = delegate
        super.init()
    }
    
    func setTrack(_ track: AWTrack) {
        guard let mediaItem = track as? MPMediaItem,
            let assetUrl = mediaItem.assetURL else { return }
        loadUrl(assetUrl)
        nowPlayingItem = mediaItem
    }
    
//    func queueNext(_ track: AWTrack, completion: (() -> Void)?) {
//        guard let nextMediaItem = track as? MPMediaItem,
//            let assetUrl = nextMediaItem.assetURL else { return }
//        print("iTunes gapless")
//        print("iTunes received: \(nextMediaItem.trackName)")
//        do {
//            isReducingGap = true
//            let nextPlayer = try AVAudioPlayer(contentsOf: assetUrl)
//            nextPlayer.stop()
//            nextPlayer.play(atTime: player.deviceCurrentTime + remainingPlaybackTime)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + gaplessDelay) {
//                self.player.stop()
//                self.player = nil
//                self.player = nextPlayer
//                print("Change nowPlayingItem")
//                self.nowPlayingItem = nextMediaItem
//                self.isReducingGap = false
//                completion?()
//            }
//        } catch let error {
//            delegate?.didReceiveError(self, error: error, priority: .test)
//        }
//
//    }
    
    func loadUrl(_ url: URL) {
        player?.stop()
        player = nil
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch let error {
            delegate?.didReceiveError(self, error: error, priority: .user)
        }
    }
    
    func play() {
        setSession(active: true)
        player?.stop()
        if playbackState == .interrupted, let nowPlayingItem = nowPlayingItem, let url = nowPlayingItem.assetURL {
            loadUrl(url)
            seekTo(currentPlaybackTime)
        }
        guard player.prepareToPlay() else {
            error = AWError(code: .iTunesPlaybackError, description: "iTunes failed to prepare to play")
            player.stop()
            playbackState = .failed
            return
        }
        guard player.play() else {
            error = AWError(code: .iTunesPlaybackError, description: "iTunes failed to play")
            player.stop()
            playbackState = .failed
            return
        }
        playbackState = .playing
    }
    
    func pause() {
        player.pause()
        playbackState = .paused
        setSession(active: false)
    }
    
    func stop() {
        player.currentTime = 0
        player.stop()
        playbackState = .stopped
    }
    
    func interrupt(reason: AudioInterruptionReason) {
        print("iTunes was interrupted")
        player.stop()
        playbackState = .interrupted
        setSession(active: false)
    }
    
    func seekTo(_ time: TimeInterval) {
        let seekTime = min(time, duration - gaplessDelay)
        
        setTimer(false)
        let shouldPlay = player.isPlaying
        player.stop()
        player.currentTime = seekTime
        guard shouldPlay else { return }
        player.prepareToPlay()
        player.play()
        setTimer(true)
    }
    
    private func setTimer(_ enable: Bool) {
        timer?.invalidate()
        guard enable else {
            timer = nil
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { t in
            self.currentPlaybackTime = self.player.currentTime
        }
    }
    
    private func prepareForNext() {
        if isReducingGap { return }
        guard let nextMediaItem = delegate?.didRequestNextItem(self) as? MPMediaItem,
            let assetUrl = nextMediaItem.assetURL else { return }
        print("iTunes gapless")
        print("iTunes received: \(nextMediaItem.trackName)")
        isReducingGap = true
        playbackState = .fetching
        do {
            let nextPlayer = try AVAudioPlayer(contentsOf: assetUrl)
            guard nextPlayer.prepareToPlay() else {
                playbackState = .failed
                error = AWError(code: .iTunesPlaybackError, description: "iTunes gapless failed to prepare to play")
                return
            }
            guard nextPlayer.play(atTime: player.deviceCurrentTime + remainingPlaybackTime) else {
                playbackState = .failed
                let error = AWError(code: .iTunesPlaybackError, description: "iTunes gapless failed to play")
                delegate?.didReceiveError(self, error: error, priority: .test)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + gaplessDelay) {
                self.player.stop()
                self.player = nil
                self.player = nextPlayer
                print("Change nowPlayingItem")
                self.nowPlayingItem = nextMediaItem
                self.playbackState = .playing
                self.isReducingGap = false
                self.delegate?.didStartPlayingNextItem(self, newItem: nextMediaItem)
            }
        } catch let error {
            playbackState = .failed
            delegate?.didReceiveError(self, error: error, priority: .test)
        }
    }
    
}

extension iTunesPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        updateMetadata()
        if isRepeating || isReducingGap { return }
        delegate?.didFinishPlayingTrack(self, successfully: flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error = error else { return }
        playbackState = .failed
        self.error = error
        delegate?.didReceiveError(self, error: error, priority: .user)
    }
}

extension AVAudioPlayer {
    var progress: Float {
        return Float(currentTime / duration)
    }
    
    var isRepeating: Bool {
        get {
            return numberOfLoops < 0
        } set {
            numberOfLoops = newValue ? -1 : 0
        }
    }
}
