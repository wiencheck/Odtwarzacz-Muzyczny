//
//  UITableView.swift
//  Plum
//
//  Created by Adam Wienconek on 15.04.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

protocol TableViewManager: UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView! { get set }
}

extension UITableView {
    func setManager(_ manager: TableViewManager) {
        manager.tableView = self
        delegate = manager
        dataSource = manager
    }
    
    func reloadData(animated: Bool,
                    options: UIView.AnimationOptions = .transitionCrossDissolve,
                    animations: (() -> Void)? = nil,
                    completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self, duration: animated ? 0.3 : 0, options: options, animations: {
            self.reloadData()
            
            if self.shouldDisplayEmptyMessage, self.isEmpty {
                let emptyView = EmptyBackgroundView(image: self.emptyMessageImage, top: self.emptyMessageTitleText, bottom: self.emptyMessageDetailText)
                self.backgroundView = emptyView
                self.separatorStyle = .none
            } else {
                if self.backgroundView is EmptyBackgroundView {
                    self.backgroundView = nil
                }
            }
            animations?()
        }, completion: completion)
    }
    
    var isEmpty: Bool {
        var number = 0
        for i in 0 ..< numberOfSections {
            number += numberOfRows(inSection: i)
        }
        return number == 0
    }
    
    private struct AssociatedKeys {
        static var shouldDisplayEmptyMessageKey: UInt8 = 0
        static var emptyMessageTitleTextKey: UInt8 = 0
        static var emptyMessageDetailTextKey: UInt8 = 0
        static var emptyMessageImageKey: UInt8 = 0
    }
    
    var shouldDisplayEmptyMessage: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.shouldDisplayEmptyMessageKey) as? Bool) ?? false
        } set {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldDisplayEmptyMessageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var emptyMessageTitleText: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyMessageTitleTextKey) as? String
        } set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyMessageTitleTextKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var emptyMessageDetailText: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyMessageDetailTextKey) as? String
        } set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyMessageDetailTextKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var emptyMessageImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyMessageImageKey) as? UIImage
        } set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyMessageImageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func setEstimatedHeights(_ enable: Bool) {
        estimatedRowHeight = enable ? UITableView.automaticDimension : 0
        estimatedSectionHeaderHeight = enable ? UITableView.automaticDimension : 0
        estimatedSectionFooterHeight = enable ? UITableView.automaticDimension : 0
    }
    
    func indexPath(absoluteRow: Int) -> IndexPath {
        var section = 0
        var row = 0
        var counter = 0
        var rowsInSection: Int!
        
        while section < numberOfSections {
            rowsInSection = numberOfRows(inSection: section)
            if absoluteRow < counter + rowsInSection {
                row = absoluteRow - counter
                break
            }
            counter += rowsInSection
            section += 1
        }
        
        return IndexPath(row: row, section: section)
    }
}
