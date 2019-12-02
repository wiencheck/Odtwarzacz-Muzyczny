//
//  AppDelegate+Spotify.swift
//  Plum
//
//  Created by Adam Wienconek on 15/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

extension AppDelegate {
    // This method gets triggerred after opening app from URL
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        /*
         Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
         helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
         */
        if SPTAuth.defaultInstance().canHandle(url) {
            NotificationCenter.default.post(name: SpotifyConstants.Notifications.sessionUrlReceived, object: url)
            return true
        }
        
        return false
    }
}
