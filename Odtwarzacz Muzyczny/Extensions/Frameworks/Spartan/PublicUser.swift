//
//  PublicUser.swift
//  Plum
//
//  Created by Adam Wienconek on 13/09/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

extension PublicUser {
    
    /*
     External url of User has dicationary
     spotify: "https://open.spotify.com/user/adwienc"
     */
    
    var canonicalUsername: String? {
        guard let value = externalUrls["spotify"] else { return nil }
        let userName = value.components(separatedBy: "/").last
        return userName
    }
}
