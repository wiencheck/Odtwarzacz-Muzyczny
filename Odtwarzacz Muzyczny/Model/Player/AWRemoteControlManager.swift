//
//  GreatRemoteControlsManager.swift
//  Musico
//
//  Created by adam.wienconek on 13.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import MediaPlayer

protocol AWRemoteControlDelegate: class {
    func togglePlayPauseRemoteCommand()
    func playRemoteCommand()
    func pauseRemoteCommand()
    func stopRemoteCommand()
    func changePlaybackPositionRemoteCommand(position: TimeInterval)
    func nextTrackRemoteCommand()
    func previousTrackRemoteCommand()
    func changeShuffleRemoteCommand()
}

extension AWRemoteControlDelegate {
    func togglePlayPauseRemoteCommand() {
        print("Not implemented")
    }
    func playRemoteCommand() {
        print("Not implemented")
    }
    func pauseRemoteCommand() {
        print("Not implemented")
    }
    func stopRemoteCommand() {
        print("Not implemented")
    }
    func changePlaybackPositionRemoteCommand(position: TimeInterval) {
        print("Not implemented")
    }
    func nextTrackRemoteCommand() {
        print("Not implemented")
    }
    func previousTrackRemoteCommand() {
        print("Not implemented")
    }
    func changeShuffleRemoteCommand() {
        print("Not implemented")
    }
}

class AWRemoteControlManager {
    
    static let shared = AWRemoteControlManager()
    
    private let remote = MPRemoteCommandCenter.shared()
    public weak var delegate: AWRemoteControlDelegate?
    
    private init() {}
    
    init(delegate: AWRemoteControlDelegate?) {
        self.delegate = delegate
        activatePlaybackCommands(true)
    }
    
    deinit {
        activatePlaybackCommands(false)
    }
    
    private func activatePlaybackCommands(_ enable: Bool) {
        if enable {
            remote.togglePlayPauseCommand.addTarget(handler: { [unowned self] _ in
                self.delegate?.togglePlayPauseRemoteCommand()
                return .success
            })
            remote.playCommand.addTarget(handler: { [unowned self] _ in
                self.delegate?.playRemoteCommand()
                return .success
            })
            remote.pauseCommand.addTarget(handler: { [unowned self] _ in
                self.delegate?.pauseRemoteCommand()
                return .success
            })
            remote.stopCommand.addTarget(handler: { [unowned self] _ in
                self.delegate?.stopRemoteCommand()
                return .success
            })
            remote.changePlaybackPositionCommand.addTarget { [unowned self] event -> MPRemoteCommandHandlerStatus in
                guard let position = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
                self.delegate?.changePlaybackPositionRemoteCommand(position: position.positionTime)
                return .success
            }
            remote.nextTrackCommand.addTarget(handler: { [unowned self] _ in
                self.delegate?.nextTrackRemoteCommand()
                return .success
            })
            remote.previousTrackCommand.addTarget(handler: { [unowned self] _ in
                self.delegate?.previousTrackRemoteCommand()
                return .success
            })
            remote.changeShuffleModeCommand.addTarget(handler: { [unowned self] _ in
                self.delegate?.changeShuffleRemoteCommand()
                return .success
            })
        } else {
            remote.playCommand.removeTarget(self)
            remote.pauseCommand.removeTarget(self)
            remote.stopCommand.removeTarget(self)
            remote.togglePlayPauseCommand.removeTarget(self)
            remote.changePlaybackPositionCommand.removeTarget(self)
            remote.nextTrackCommand.removeTarget(self)
            remote.previousTrackCommand.removeTarget(self)
            remote.changeShuffleModeCommand.removeTarget(self)
        }
    }
    
    public func enableControls(_ enable: Bool) {
        remote.playCommand.isEnabled = enable
        remote.pauseCommand.isEnabled = enable
        remote.stopCommand.isEnabled = enable
        remote.togglePlayPauseCommand.isEnabled = enable
        remote.changePlaybackPositionCommand.isEnabled = enable
        remote.nextTrackCommand.isEnabled = enable
        remote.previousTrackCommand.isEnabled = enable
        remote.changeShuffleModeCommand.isEnabled = enable
    }
    
    private func addTarget() {
        remote.togglePlayPauseCommand.addTarget(handler: { [unowned self] _ in
            self.delegate?.togglePlayPauseRemoteCommand()
            return .success
        })
        remote.playCommand.addTarget(handler: { [unowned self] _ in
            self.delegate?.playRemoteCommand()
            return .success
        })
        remote.pauseCommand.addTarget(handler: { [unowned self] _ in
            self.delegate?.pauseRemoteCommand()
            return .success
        })
        remote.stopCommand.addTarget(handler: { [unowned self] _ in
            self.delegate?.stopRemoteCommand()
            return .success
        })
        remote.changePlaybackPositionCommand.addTarget { [unowned self] event -> MPRemoteCommandHandlerStatus in
            guard let position = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.delegate?.changePlaybackPositionRemoteCommand(position: position.positionTime)
            return .success
        }
        remote.nextTrackCommand.addTarget(handler: { [unowned self] _ in
            self.delegate?.nextTrackRemoteCommand()
            return .success
        })
        remote.previousTrackCommand.addTarget(handler: { [unowned self] _ in
            self.delegate?.previousTrackRemoteCommand()
            return .success
        })
        remote.changeShuffleModeCommand.addTarget(handler: { [unowned self] _ in
            self.delegate?.changeShuffleRemoteCommand()
            return .success
        })
    }
    
    private func removeTarget() {
        remote.playCommand.removeTarget(self)
        remote.pauseCommand.removeTarget(self)
        remote.stopCommand.removeTarget(self)
        remote.togglePlayPauseCommand.removeTarget(self)
        remote.changePlaybackPositionCommand.removeTarget(self)
        remote.nextTrackCommand.removeTarget(self)
        remote.previousTrackCommand.removeTarget(self)
        remote.changeShuffleModeCommand.removeTarget(self)
    }
    
    private func en(enable: Bool) {
        remote.playCommand.isEnabled = enable
        remote.pauseCommand.isEnabled = enable
        remote.stopCommand.isEnabled = enable
        remote.togglePlayPauseCommand.isEnabled = enable
        remote.changePlaybackPositionCommand.isEnabled = enable
        remote.nextTrackCommand.isEnabled = enable
        remote.previousTrackCommand.isEnabled = enable
        remote.changeShuffleModeCommand.isEnabled = enable
    }
}
