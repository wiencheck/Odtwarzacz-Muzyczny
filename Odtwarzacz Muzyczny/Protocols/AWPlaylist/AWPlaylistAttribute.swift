//
//  AWPlaylistAttribute.swift
//  Plum
//
//  Created by Adam Wienconek on 10.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

enum PlaylistAttribute: Int, CaseIterable {
    case folder
    case child
    case smart
    case genius
    case sourced
    case shared
    case `private`
}

//struct PlaylistAttribute: OptionSet, Codable {
//    let rawValue: Int
//
//    static let folder = PlaylistAttribute(rawValue: 1 << 0)
//    static let smart = PlaylistAttribute(rawValue: 1 << 1)
//    static let genius = PlaylistAttribute(rawValue: 1 << 2)
//    static let child = PlaylistAttribute(rawValue: 1 << 3)
//    static let editable = PlaylistAttribute(rawValue: 1 << 4)
//    static let iTunes = PlaylistAttribute(rawValue: 1 << 5)
//    static let spotify = PlaylistAttribute(rawValue: 1 << 6)
//
//    func toString() -> [String] {
//        var arr = [String]()
//        if contains(.folder) {
//            arr.append("folder")
//        }
//        if contains(.smart) {
//            arr.append("smart")
//        }
//        if contains(.genius) {
//            arr.append("genius")
//        }
//        if contains(.child) {
//            arr.append("child")
//        }
//        if contains(.editable) {
//            arr.append("editable")
//        }
//        return arr
//    }
//}
