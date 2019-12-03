//
//  PlayerViewModel.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 03/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import Foundation

protocol PlayerViewModelDelegate: class, Loadable, Errorable {
    func playbackStateDidChange(state: PlaybackState)
    func shuffleStateDidChange(enabled: Bool)
    func repeatModeDidChange(mode: RepeatMode)
    func audioRouteDidChange(route: AudioOutputRoute)
    func nowPlayingModelDidChange(model: PlayerViewModel.NowPlayingModel)
    func nextPlayingModelDidChange(model: PlayerViewModel.NextPlayingModel?)
}

class PlayerViewModel {
    
    private let player: AWPlayer
    
    weak var delegate: PlayerViewModelDelegate? {
        didSet {
            delegate?.playbackStateDidChange(state: player.playbackState)
            delegate?.shuffleStateDidChange(enabled: player.isShuffling)
            delegate?.repeatModeDidChange(mode: player.repeatMode)
            delegate?.audioRouteDidChange(route: player.currentAudioRoute)
            fetchNowPlayingModel(item: player.nowPlayingItem)
        }
    }
    
    var nowPlayingItem: AWTrack? {
        return player.nowPlayingItem
    }
    
    var currentPlaybackTime: TimeInterval {
        return player.currentPlaybackTime
    }
    
    private var shouldFetchLyrics = false
    private var shouldFetchRating = false
    
    init() {
        player = AppContext.shared.player
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    func fetchNowPlayingModel(item: AWTrack?) {
        guard let item = item else {
            delegate?.nowPlayingModelDidChange(model: .default)
            return
        }
        let image = item.artwork(for: .large)
        let model = NowPlayingModel(title: item.trackName,
                                        album: item.albumName,
                                        artist: item.artistName,
                                        duration: item.duration,
                                        image: image,
                                        imageUrl: item.artworkUrl(for: .large), source: item.source)
        delegate?.nowPlayingModelDidChange(model: model)
    }
    
    private func fetchNextPlayingModel(next item: AWTrack?) {
        guard let item = item else {
            delegate?.nextPlayingModelDidChange(model: nil)
            return
        }
        let model = NextPlayingModel(title: item.trackName, detail: item.artistName)
        self.delegate?.nextPlayingModelDidChange(model: model)
    }
    
    @objc func togglePlayback() {
        player.togglePlayback()
    }
    
    @objc func skipToPreviousTrackUsingForce() {
        player.skipToPrevious(force: true)
    }
    
    @objc func skipToPreviousTrack() {
        player.skipToPrevious(force: false)
    }
    
    @objc func skipToNextTrack() {
        player.skipToNextTrack()
    }
    
    @objc func toggleRepeatMode() {
        player.toggleRepeat()
    }
    
    @objc func toggleShuffleMode() {
        player.toggleShuffle()
    }
    
    func didChangeTimeSlider(newTime: TimeInterval) {
        player.seek(to: newTime)
    }
    
    func didPressRemoveNextButton() {
        player.removeNext()
    }
    
}

extension PlayerViewModel {
    
    private func handleTrackChanged(_ sender: Notification) {
        fetchNowPlayingModel(item: player.nowPlayingItem)
        fetchNextPlayingModel(next: player.nextPlayingItem)
    }
    
    private func handlePlaybackStateChanged(_ sender: Notification) {
        guard let state = sender.object as? PlaybackState else { return }
        delegate?.playbackStateDidChange(state: state)
    }
    
    private func handleShuffleStateChanged(_ sender: Notification) {
        guard let enabled = sender.object as? Bool else { return }
        delegate?.shuffleStateDidChange(enabled: enabled)
    }
    
    private func handleRepeatStateChanged(_ sender: Notification) {
        guard let mode = sender.object as? RepeatMode else { return }
        fetchNextPlayingModel(next: player.nextPlayingItem)
        delegate?.repeatModeDidChange(mode: mode)
    }
    
    private func handleQueueChanged(_ sender: Notification) {
        fetchNextPlayingModel(next: player.nextPlayingItem)
    }
    
    private func handleAudioRouteChanged(_ sender: Notification) {
        guard let route = sender.object as? AudioOutputRoute else { return }
        delegate?.audioRouteDidChange(route: route)
    }
    
    func addObservers() {
        let pairs: [(Notification.Name, ((Notification) -> Void))] = [
            (AWPlayer.trackChangedNotification, { notification in
                self.handleTrackChanged(notification)
            }),
            (AWPlayer.audioRouteChangedNotification, { notification in
                self.handleAudioRouteChanged(notification)
            }),
            (AWPlayer.repeatModeChangedNotification, { notification in
                self.handleRepeatStateChanged(notification)
            }),
            (AWPlayer.playbackModeChangedNotification, { notification in
                self.handleShuffleStateChanged(notification)
            }),
            (AWPlayer.playbackStateChangedNotification, { notification in
                self.handlePlaybackStateChanged(notification)
            }),
            (AWPlayer.defaultQueueChangedNotification, { notification in
                self.handleQueueChanged(notification)
            }),
            (AWPlayer.userQueueChangedNotification, { notification in
                self.handleQueueChanged(notification)
            })
        ]
        
        pairs.forEach { name, callback in
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: callback)
        }
    }
    
    func removeObservers() {
        //trackProgressTimer?.invalidate()
    }
}

extension PlayerViewModel {
    public struct NowPlayingModel {
        let title: String
        let album: String
        let artist: String
        let duration: TimeInterval
        let image: UIImage?
        let imageUrl: URL?
        let source: AWMediaSource?
        
        static let `default` = NowPlayingModel(title: "Empty",
                                                   album: "Empty",
                                                   artist: "Empty",
                                                   duration: 0,
                                                   image: nil,
                                                   imageUrl: nil,
                                                   source: nil)
    }
    
    public struct NextPlayingModel {
        let title: String
        let detail: String?
        
        init(title: String, detail: String?) {
            self.title = title
            self.detail = detail
        }
        
        static let empty = NextPlayingModel(title: LocalizedStringKey.endOfQueue.localized, detail: nil)
    }
}
