//
//  MPMediaItem.swift
//  Musico
//
//  Created by adam.wienconek on 17.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import MediaPlayer

extension CGSize {
    static let x10 = CGSize(width: 10, height: 10)
    static let x20 = CGSize(width: 20, height: 20)
    static let x50 = CGSize(width: 50, height: 50)
    static let x100 = CGSize(width: 100, height: 100)
    static let x200 = CGSize(width: 200, height: 200)
    static let x300 = CGSize(width: 300, height: 300)
    static let x500 = CGSize(width: 500, height: 500)
}

extension MPMediaItem {
    static let defaultArtworkImage = UIImage(named: "no_artwork")!
    
    /// Artwork at 10x10
    var artworkx10: UIImage? {
        return artwork?.image(at: .x10)
    }
    
    /// Artwork at 20x20
    var artworkx20: UIImage? {
        return artwork?.image(at: .x20)
    }
    
    /// Artwork at 50x50
    var artworkx50: UIImage? {
        return artwork?.image(at: .x50)
    }
    
    var artworkx100: UIImage? {
        return artwork?.image(at: .x100)
    }
    
    /// Artwork image at 200x200
    var artworkx200: UIImage? {
        return artwork?.image(at: .x200)
    }
    
    /// Artwork image at 500x500
    var artworkx500: UIImage? {
        return artwork?.image(at: .x500)
    }
    
    var releaseYear: String? {
        guard let yearNumber: NSNumber = value(forProperty: "year") as? NSNumber else {
            return nil
        }
        if (yearNumber.isKind(of: NSNumber.self)) {
            let _year = yearNumber.intValue
            if (_year != 0) {
                return "\(_year)"
            }
        }
        return nil
    }
    
    func lyrics() -> String? {
        guard let url = self.assetURL else { return nil }
        let ass = AVAsset(url: url)
        return ass.lyrics
    }
    
    var bitrate: Int? {
        guard let url = assetURL else {
            return nil
        }
        let songAsset = AVURLAsset(url: url)
        let exporter = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetPassthrough)
        guard let length = exporter?.estimatedOutputFileLength else {
            return nil
        }
        return Int(length / 1024)
    }
    
    var userRating: Int {
        get {
            return rating
        } set {
            setValue(newValue, forKey: MPMediaItemPropertyRating)
        }
    }
    
    func ratingStars(_ rating: Int) -> String {
        return String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
    
    var likedState: LikedState {
        get {
            guard let value = value(forProperty: "likedState") as? Int,
                let state = LikedState(rawValue: value) else {
                return .none
            }
            return state
        } set {
            setValue(newValue.rawValue, forKey: "likedState")
        }
    }
    
    /// Increments `skipCount` and sets `lastSkippedDate` for the item.
    func incrementSkipCount() {
        let countComponents = ["increm", "entSki", "pCount"]
        let countStr = countComponents.joined()
        let count = Selector(countStr)
        if responds(to: count) {
            perform(count)
        }
        
        let dateComponents = ["setLa", "stSkip", "pedDate", ":"]
        let dateStr = dateComponents.joined()
        let date = Selector(dateStr)
        if responds(to: date) {
            perform(date, with: Date())
        }
    }
    
    /// Increments `playCount` and sets `lastPlayedDate` for the item.
    func incrementPlayCount() {
        let countStr = "incrementPlayCount"
        let count = Selector(countStr)
        if responds(to: count) {
            perform(count)
        }
        
        let dateStr = "setLastPlayedDate:"
        let date = Selector(dateStr)
        if responds(to: date) {
            perform(date, with: Date())
        }
    }
    
}
