//
//  Player.swift
//  
//
//  Created by adam.wienconek on 08.02.2019.
//

import AVFoundation

enum ErrorPriority: Int {
    case debug
    case test
    case user
}

typealias MessagePriority = ErrorPriority

protocol PlayerDelegate: class {
    func didReceiveMessage(_ player: Player, message: String, priority: MessagePriority)
    func didReceiveError(_ player: Player, error: Error, priority: ErrorPriority)
    func didFinishPlayingTrack(_ player: Player, successfully: Bool)
    
    func didChangePlaybackState(_ player: Player, newState: PlaybackState)
    
    /// Players should observe the current playback time of the internal player on their own and report the time continuosly using this method.
    func didChangePlaybackTime(_ player: Player, newTime: TimeInterval)
    
    /// Returns the next item from queue.
    func didRequestNextItem(_ player: Player) -> AWTrack?
    
    /// Called after player started playing the item requested in `didRequestNextItem` method.
    func didStartPlayingNextItem(_ player: Player, newItem: AWTrack)
}

protocol Player: class {
    
    init(delegate: PlayerDelegate?)
    
    func setTrack(_ track: AWTrack)
    
    /**
     Starts/resumes playback of item loaded in the 'setTrack' method.
     Always activate the audio session before issuing play command to the internal player.
     */
    func play()
    
    /**
     Pauses playback.
     Always deactivate audio session after your internal player has stopped playing.
     */
    func pause()
    
    /**
     Stops playback and deactivates the player.
     Because this method is called when players change between two songs, you should NOT deactivate audio session here.
     */
    func stop()
    
    /**
     Changes the playback position of player.
     
     - Parameters:
        - time: Time the player should scrub to
     */
    func seekTo(_ time: TimeInterval)
    
    /**
     Interrupts the playback. You should pause the internal player and deactivate audio session immediately after.
     
     - Parameters:
        - reason: Reason for interruption.
     */
    func interrupt(reason: AudioInterruptionReason)
    
    /// Delegate object for handling events and requests.
    var delegate: PlayerDelegate? { get set }
    
    /// Estimated time (in seconds) required for player to prepare gapless playback for next item.
    var gaplessDelay: TimeInterval { get }
    
    ///
    var source: AWMediaSource { get }
    
    /// Currently loaded track.
    var nowPlayingTrack: AWTrack? { get }
    
    /// Current playback position time (in seconds).
    var currentPlaybackTime: TimeInterval { get }
    
    /// Duration of sound loaded into internal player.
    var duration: TimeInterval { get }
    
    /// Value indicating if the internal player is looping current item. Set to enable/disable looping.
    var isRepeating: Bool { get set }
    
    /// Value indicating if the internal player is currently playing.
    var isPlaying: Bool { get }
    
    /// Remaining time to the end of playback (in seconds)
    var remainingPlaybackTime: TimeInterval { get }
    
    /// Current playback state.
    var playbackState: PlaybackState { get }
    
    /// An optional error. If `playbackState` is `failed` this value will be non-nil.
    var error: Error? { get }
}

extension Player {
    var isPlaying: Bool {
        return playbackState.isPlayingState
    }
    
    var remainingPlaybackTime: TimeInterval {
        return duration - currentPlaybackTime
    }
    
    /**
     Activates or deactivates audio session.
     
     - Returns: optional error if setting the session failed for some reason.
    */
    @discardableResult
    func setSession(active: Bool) -> Error? {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(active)
            return nil
        } catch let error {
            print("*** Failed to activate audio session: \(error.localizedDescription)")
            return error
        }
    }
}
