//
//  PlaylistsMasterCollectionManager.swift
//  Plum
//
//  Created by Adam Wienconek on 28.05.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

class PlaylistsMasterCollectionManager: NSObject, CollectionViewManager {
    
    enum SectionType: Int {
        case folders
        case smart
        case normal
    }
    
    internal weak var collectionView: UICollectionView!
    private weak var viewModel: PlaylistsMasterViewModel!
    init(model: PlaylistsMasterViewModel) {
        viewModel = model
    }
    
    // MARK: Datasource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("numberofsections \(viewModel.numberOfSections)")
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlaylistCollectionCell
        
        let model = viewModel.cellViewModel(for: indexPath)
        cell.configure(with: model)
        
        /* Tagging cells will make sure that correct image get placed in cell */
        cell.tag = indexPath.row
        viewModel.image(for: indexPath) { image in
            DispatchQueue.main.async {
                guard cell.tag == indexPath.row else { return }
                cell.imageView.image = image.image
            }
        }
        return cell
    }
    
    // MARK: Header methods
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: 44)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableHeaderFooterView(kind: kind, indexPath: indexPath) as CollectionHeaderView
//        header.configure(with: viewModel.headerModel(for: indexPath))
//        header.applyTheme(.default)
//        return header
//    }
    
    // MARK: Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.didSelectRow(at: indexPath)
    }
}
