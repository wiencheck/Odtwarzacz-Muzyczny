//
//  String.swift
//  Musico
//
//  Created by adam.wienconek on 01.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

extension String {
    struct SpecialCharacters {
        static let star_full = "★"
        static let star_empty = "☆"
        static let heart_full = "♥︎"
        static let heart_empty = "♡"
        static let dot_middle = "•"
    }
        
    init?(_ opt: Int?) {
        if let opt = opt {
            self = String(opt)
        } else {
            return nil
        }
    }
    
    static let articles = ["A", "AN", "THE"]
    
    /// Returns string without an instance of article at the beginning
    func dropArticle() -> String {
        let comp = components(separatedBy: " ")
        if let first = comp.first?.uppercased(), String.articles.contains(first), comp.count > 1 {
            let range = 1 ..< comp.count
            return comp[range].joined(separator: " ")
        }
        return self
    }
    
//    func hasPrefix(_ prefixes: [String]) -> Bool {
//        for prefix in prefixes {
//            if hasPrefix(prefix) {
//                return true
//            }
//        }
//        return false
//    }
    
//    mutating func removePrefix(_ prefix: String) {
//        guard hasPrefix(prefix) else { return }
//        self = String(dropFirst(prefix.count))
//    }
//    
//    func removePrefix(_ prefix: String) -> String {
//        guard hasPrefix(prefix) else { return self }
//        return String(dropFirst(prefix.count))
//    }
//    
//    mutating func removePrefixes(_ prefixes: [String]) {
//        guard hasPrefix(prefixes) else { return }
//        for prefix in prefixes {
//            if hasPrefix(prefix) {
//                self = String(dropFirst(prefix.count))
//            }
//        }
//        return
//    }
//    
//    func removePrefixes(_ prefixes: [String]) -> String {
//        guard hasPrefix(prefixes) else { return self }
//        for prefix in prefixes {
//            if hasPrefix(prefix) {
//                return String(dropFirst(prefix.count))
//            }
//        }
//        return self
//    }
    
    /// Ascending sorting predicate which places occurences with symbols other that letters at the end of sorted collection.
    static let alphanumericsAscendingSort: (String, String) -> Bool = { s1, s2 -> Bool in
        guard let f1 = s1.first, let f2 = s2.first else {
            return s1 < s2
        }
        if f1.isLetter == false && f2.isLetter {
            return false
        }
        if f1.isLetter && f2.isLetter == false {
            return true
        }
        if f1.isNumber == false && f2.isNumber {
            return false
        }
        if f1.isNumber && f2.isNumber == false {
            return true
        }
        return s1 < s2
    }
    
    /// Descending sorting predicate which places occurences with symbols other that letters at the end of sorted collection.
    static let alphanumericsDescendingSort: (String, String) -> Bool = { s1, s2 -> Bool in
        guard let f1 = s1.first, let f2 = s2.first else {
            return s1 > s2
        }
        if f1.isLetter == false && f2.isLetter {
            return false
        }
        if f1.isLetter && f2.isLetter == false {
            return true
        }
        if f1.isNumber == false && f2.isNumber {
            return false
        }
        if f1.isNumber && f2.isNumber == false {
            return true
        }
        return s1 > s2
    }

}

