//
//  AWMediaSource.swift
//  Plum
//
//  Created by Adam Wienconek on 10.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

/// Enum used for distinguishing between items from different music sources
enum AWMediaSource: String, Codable, CaseIterable {
    case spotify = "Spotify"
    case iTunes = "iTunes"
    
    static func factory(from rawValue: String) -> AWMediaSource {
        switch rawValue.lowercased() {
        case "spotify":
            return .spotify
        case "itunes":
            return .iTunes
        default:
            return AWMediaSource(rawValue: rawValue)!
        }
    }
}

extension AWMediaSource {
    /// Color used to differentiate items from different sources.
    var color: UIColor? {
        switch self {
        case .iTunes:
            return UIColor.systemPink
        case .spotify:
            return UIColor.systemGreen
        }
    }
}
