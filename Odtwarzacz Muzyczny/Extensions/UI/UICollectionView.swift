//
//  UICollectionView.swift
//  Plum
//
//  Created by Adam Wienconek on 16.04.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

protocol CollectionViewManager: UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView! { get set }
}

extension UICollectionView {
    func setManager(_ manager: CollectionViewManager) {
        manager.collectionView = self
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
            } else {
                self.backgroundView = nil
            }
            animations?()
        }, completion: completion)
    }
    
    var isEmpty: Bool {
        var number = 0
        for i in 0 ..< numberOfSections {
            number += numberOfItems(inSection: i)
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
            if newValue != nil {
                shouldDisplayEmptyMessage = true
            }
            objc_setAssociatedObject(self, &AssociatedKeys.emptyMessageTitleTextKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var emptyMessageDetailText: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyMessageDetailTextKey) as? String
        } set {
            if newValue != nil {
                shouldDisplayEmptyMessage = true
            }
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
    
    func scrollToSectionTop(_ section: Int, animated: Bool) {
        if let attributes = layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)) {
            var offsetY = attributes.frame.origin.y - contentInset.top
            if #available(iOS 11.0, *) {
                offsetY -= safeAreaInsets.top
            }
            setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)
        }
    }
    
    private static let CollectionHeaderViewTag = 9941643
    
    var collectionHeaderView: UIView? {
        get {
            return viewWithTag(UICollectionView.CollectionHeaderViewTag)
        } set {
            if let header = newValue {
                asssignCustomHeaderView(headerView: header, sideMarginInsets: header.frame.minX)
            } else {
                removeCustomHeaderView()
            }
        }
    }
    
    private func asssignCustomHeaderView(headerView: UIView, sideMarginInsets: CGFloat = 0) {
        guard self.viewWithTag(UICollectionView.CollectionHeaderViewTag) == nil else {
            return
        }
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame = CGRect(x: sideMarginInsets, y: -height + self.contentInset.top, width: self.frame.width - (2 * sideMarginInsets), height: height)
        headerView.tag = UICollectionView.CollectionHeaderViewTag
        self.addSubview(headerView)
        self.contentInset = UIEdgeInsets(top: height, left: self.contentInset.left, bottom: self.contentInset.bottom, right: self.contentInset.right)
    }
    
    private func removeCustomHeaderView() {
        if let customHeaderView = viewWithTag(UICollectionView.CollectionHeaderViewTag) {
            let headerHeight = customHeaderView.frame.height
            customHeaderView.removeFromSuperview()
            self.contentInset = UIEdgeInsets(top: self.contentInset.top - headerHeight, left: self.contentInset.left, bottom: self.contentInset.bottom, right: self.contentInset.right)
        }
    }
}
