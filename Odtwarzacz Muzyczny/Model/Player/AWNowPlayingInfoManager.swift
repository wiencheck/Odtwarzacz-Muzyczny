//
//  AWMPNowPlayingInfoManager.swift
//  Musico
//
//  Created by adam.wienconek on 13.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import MediaPlayer

protocol MPNowPlayingInfoProvider: class {
    var nowPlayingInfoTitle: String? { get }
    var nowPlayingInfoAlbumTitle: String? { get }
    var nowPlayingInfoArtist: String? { get }
    var nowPlayingInfoPlaybackRate: Double? { get }
    var nowPlayingInfoCurrentPlaybackTime: TimeInterval? { get }
    var nowPlayingInfoPlaybackDuration: TimeInterval? { get }
    var nowPlayingInfoCollectionIdentifier: String? { get }
    var nowPlayingInfoArtwork: MPMediaItemArtwork? { get }
    var nowPlayingInfoQueueCount: UInt? { get }
    var nowPlayingInfoQueueIndex: UInt? { get }
    var nowPlayingInfoServiceProvider: String? { get }
}

class AWNowPlayingInfoManager {
        
    private let cc = MPNowPlayingInfoCenter.default()
    public weak var delegate: MPNowPlayingInfoProvider? {
        didSet {
            setTimer(delegate != nil)
        }
    }
    
    private var timer: Timer!
    private func setTimer(_ enabled: Bool) {
        guard enabled else {
            timer.invalidate()
            timer = nil
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
            self.updateNowPlayingInfo()
        }
        timer.tolerance = 2
    }
    
    private var trackObserver: Any?
    private var stateObserver: Any?
    
    init(delegate: MPNowPlayingInfoProvider) {
        self.delegate = delegate
        setTimer(true)
    }
    
    deinit {
        cc.nowPlayingInfo = nil
        setTimer(false)
    }
    
    public func updateNowPlayingInfo() {
        var nowPlayingInfo = cc.nowPlayingInfo ?? [:]
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = delegate?.nowPlayingInfoTitle

        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = delegate?.nowPlayingInfoAlbumTitle

        nowPlayingInfo[MPMediaItemPropertyArtist] = delegate?.nowPlayingInfoArtist
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = delegate?.nowPlayingInfoCurrentPlaybackTime
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = delegate?.nowPlayingInfoPlaybackDuration
        
        nowPlayingInfo[MPNowPlayingInfoCollectionIdentifier] = delegate?.nowPlayingInfoCollectionIdentifier
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = delegate?.nowPlayingInfoQueueCount
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = delegate?.nowPlayingInfoQueueIndex

        nowPlayingInfo[MPNowPlayingInfoPropertyServiceIdentifier] = delegate?.nowPlayingInfoServiceProvider

        // 1 means audio is playing
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = delegate?.nowPlayingInfoArtwork
        
        cc.nowPlayingInfo = nowPlayingInfo
    }
}
