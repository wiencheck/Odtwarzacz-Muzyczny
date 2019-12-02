//
//  SongsTableManager.swift
//  Plum
//
//  Created by Adam Wienconek on 04.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

class SongsTableManager: NSObject, TableViewManager {
    
    internal weak var tableView: UITableView!
    private weak var viewModel: SongsViewModel!
    init(model: SongsViewModel) {
        viewModel = model
    }
    
    // MARK: Datasource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let queuePath = viewModel.queueCellPath, indexPath == queuePath {
            let cell = tableView.dequeueReusableCell(withIdentifier: "queue", for: indexPath) as! QueueTableViewCell
            cell.delegate = viewModel
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "media", for: indexPath)

            let model = viewModel.cellViewModel(for: indexPath)
            cell.configure(with: model)
            
            /* Tagging cells will make sure that correct image get placed in cell */
            cell.tag = indexPath.row
            viewModel.getImage(for: indexPath, size: .small) { image in
                DispatchQueue.main.async {
                    guard cell.tag == indexPath.row else { return }
                    cell.imageView?.image = image
                }
            }
            return cell
        }
    }
    
    // MARK: Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.compactCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle(for: section)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.unloadQueueCell(false)
    }

    
//    private weak var previousHeader: TableHeaderView?
//    
//    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
//        // Pushing up
//        guard let lastPath = tableView.indexPathsForVisibleRows?.last else { return }
//        if lastPath.section >= section {
//            
//            // Previous header
//            print("previous: \(viewModel.sectionIndexes[lastPath.section - 1])")
////            previousHeader = tableView.headerView(forSection: lastPath.section - 1) as? TableHeaderView
////            previousHeader?.isActive = false
//            (tableView.headerView(forSection: lastPath.section - 1) as? TableHeaderView)?.isActive = false
//            
//            // Current header
//            print("current: \(viewModel.sectionIndexes[lastPath.section])")
//            (tableView.headerView(forSection: lastPath.section) as? TableHeaderView)?.isActive = true
//            
//            print("the next header is stuck to the top")
//        }
//    }
//    
//    private weak var nextHeader: TableHeaderView?
//    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        guard let firstPath = tableView.indexPathsForVisibleRows?.first else { return }
//        
//        //compare the section for the header that just appeared to the section
//        //for the top-most cell in the table view
//        if firstPath.section == section {
//            // Previous header
//            print("previous: \(viewModel.sectionIndexes[firstPath.section + 1])")
////            nextHeader = tableView.headerView(forSection: firstPath.section + 1) as? TableHeaderView
////            nextHeader?.isActive = false
//            (tableView.headerView(forSection: firstPath.section + 1) as? TableHeaderView)?.isActive = false
//            
//            // Current header
//            print("current: \(viewModel.sectionIndexes[firstPath.section])")
//            (tableView.headerView(forSection: firstPath.section) as? TableHeaderView)?.isActive = true
//            
//            print("the next header is stuck to the top")
//        }
//    }
    
}
