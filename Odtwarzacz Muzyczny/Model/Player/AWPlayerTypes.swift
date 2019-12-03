//
//  AWPlayerTypes.swift
//  Musico
//
//  Created by adam.wienconek on 13.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import AVFoundation

public enum PlaybackState {
    case initial
    case playing
    case paused
    case stopped
    case fetching
    case interrupted
    case failed
    
    var isPlayingState: Bool {
        if self == .playing {
            return true
        }
        if self == .fetching {
            return true
        }
        return false
    }
}

public enum RepeatMode: Int, Codable, CustomStringConvertible {
    case none
    case context
    case one
    
    public var description: String {
        switch self {
        case .none: return "None"
        case .context: return "Context"
        case .one: return "One"
        }
    }
}

public enum AudioOutputRouteType: String {
    case `default`
    case speaker = "Speaker"
    case headphones = "Headphones"
    case bluetooth = "BluetoothA2DPOutput"
    case airplay = "AirPlay"
}

public enum AudioInterruptionReason: Int {
    case routeChange
    case other
}

public struct AudioOutputRoute {
    let name: String
    let type: AudioOutputRouteType
    
    static let `default` = AudioOutputRoute(name: "Default", type: .default)
    
    init(name: String, type: AudioOutputRouteType) {
        self.name = name
        self.type = type
    }
    
    init?(route: AVAudioSessionRouteDescription) {
        guard let output = route.outputs.first,
            let type = AudioOutputRouteType(rawValue: output.portType.rawValue) else {
            return nil
        }
        self.type = type
        self.name = output.portName
    }
}
