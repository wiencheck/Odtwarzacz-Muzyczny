//
//  SpartanBaseObject.swift
//  Plum
//
//  Created by Adam Wienconek on 04/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan
import RealmSwift

extension SpartanBaseObject {
    var uid: String {
        return uri.components(separatedBy: ":").last!
//        return uri?.components(separatedBy: ":").last ?? Constants.unknownUid
    }
}

//// The underlying class for this is NSObject
//extension SpartanBaseObject {
//    public override var hash: Int {
//        return uid.hashValue
//    }
//    
//    public override func isEqual(_ object: Any?) -> Bool {
//        if let hashable = object as? NSObject {
//            return hashValue == hashable.hashValue
//        }
//        if let base = object as? SpartanBaseObject {
//            return uid == base.uid
//        } else if let saved = object as? SavedTrack {
//            return uid == saved.track.uid
//        } else if let rlm = object as? Object,
//            let primaryKey = rlm.primaryKey {
//            return uid == primaryKey
//        }
//        return super.isEqual(object)
//    }
//}
//
//// This is `pure Swift` class with field `Track` which is of type `Track: SpartanBaseObject` which I want to use for hashing and comparing
//extension SavedTrack {
//    public override var hash: Int {
//        return track.uid.hashValue
//    }
//    
//    public override func isEqual(_ object: Any?) -> Bool {
////        if let c = object as? AnyClass, let h = c as? (AnyObject & An) {
////
////        }
//        if let hashable = object as? NSObject {
//            return hashValue == hashable.hashValue
//        }
//        if let saved = object as? SavedTrack {
//            return track.uid == saved.track.uid
//        } else if let base = object as? SpartanBaseObject {
//            return track.uid == base.uid
//        } else if let rlm = object as? Object,
//            let key = rlm.primaryKey {
//            return track.uid == key
//        }
//        return super.isEqual(object)
//    }
//}
////extension SavedTrack: Hashable {
////    public static func == (lhs: SavedTrack, rhs: SavedTrack) -> Bool {
////        return lhs.track.uid == rhs.track.uid
////    }
////
////    public func hash(into hasher: inout Hasher) {
////        hasher.combine(track.uid)
////    }
////}
//
//// This is my custom class which inherits from `Object` which inherits from `NSObject`
////extension RealmTrack {
////    override var hash: Int {
////        return _trackUid.hashValue
////    }
////    
////    override func isEqual(_ object: Any?) -> Bool {
////        if let hashable = object as? NSObject {
////            return hashValue == hashable.hashValue
////        }
////        if let rlm = object as? RealmTrack {
////            return _trackUid == rlm._trackUid
////        } else if let saved = object as? SavedTrack {
////            return _trackUid == saved.track.uid
////        } else if let base = object as? SpartanBaseObject {
////            return _trackUid == base.uid
////        }
////        return super.isEqual(object)
////    }
////}
