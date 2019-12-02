//
//  SpotifyConstants.swift
//  Plum
//
//  Created by adam.wienconek on 22.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation

enum SpotifyConstants {
//    private static let plistName = "SpotifyValues"
//    
//    static var clientID: String {
//        return PlistReader.property(from: plistName, key: "clientID") as! String
//    }
//    static var tokenSwapURL: URL {
//        return URL(string: PlistReader.property(from: plistName, key: "tokenSwapUrl") as! String)!
//    }
//    static var tokenRefreshURL: URL {
//        return URL(string: PlistReader.property(from: plistName, key: "tokenRefreshUrl") as! String)!
//    }
//    static var redirectURL: URL {
//        return URL(string: PlistReader.property(from: plistName, key: "redirectUrl") as! String)!
//    }
//    static var sessionUserDefaultsKey: String {
//        return PlistReader.property(from: plistName, key: "sessionDefaultsKey") as! String
//    }
//    static var usernameDefaultsKey: String {
//        return PlistReader.property(from: plistName, key: "userDefaultsKey") as! String
//    }
    static let clientID = "2f7173acc66d4417801bcefada423e84"
    static let tokenSwapURL = URL(string: "https://plum-spotify-token-swap.herokuapp.com/api/token")!
    static let tokenRefreshURL = URL(string: "https://plum-spotify-token-swap.herokuapp.com/api/refresh_token")!
    static let redirectURL = URL(string: "odtw://")!
    static let sessionUserDefaultsKey = "spotifySessionUserDefaults"
    static let usernameDefaultsKey = "spotifyUsername"
    
    struct Notifications {
        static let sessionUrlReceived = Notification.Name("sessionUrlReceived")
        static let sessionUpdated = Notification.Name("sessionUpdated")
        static let playerLoggedStatusChanged = Notification.Name("playerLoggedStatusChanged")
        static let playerDisconnected = Notification.Name("playerDisconnected")
        static let playerConnected = Notification.Name("playerConnected")
        static let playerBitrateDidChange = Notification.Name("playerBitrateDidChange")
        static let localLibraryDidChange = Notification.Name("localLibraryDidChange")
    }
}
