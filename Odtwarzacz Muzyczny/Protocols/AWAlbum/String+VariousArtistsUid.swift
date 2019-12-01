//
//  String+VariousArtistsUid.swift
//  Plum
//
//  Created by Adam Wienconek on 10.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

extension String {
    /// Identifier used to query albums by various artists.
    static let variousArtistsUid = "1"
    static let favouriteTracksUid = "fT"
    
    static let recentlyAddedSectionTitle = LocalizedStringKey.recentlyAddedSectionTitle.localized
    static var recentlyAddedSectionCompactTitle: String {
        return recentlyAddedSectionTitle.getAcronyms()
    }

}

extension String
{
    public func getAcronyms(separator: String = "", joined: Bool = false) -> String
    {
        let comp = components(separatedBy: " ").compactMap { c -> String? in
            guard let first = c.first else { return nil }
            return String(first)
        }
        if joined {
            return comp.joined(separator: separator)
        }
        return comp.joined()
    }
}
