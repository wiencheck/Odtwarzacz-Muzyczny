//
//  PlaylistDetailTableManager.swift
//  Plum
//
//  Created by Adam Wienconek on 28.05.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

class PlaylistDetailTableManager: NSObject, TableViewManager {
    
    var topMargin: CGFloat = 0
    
    internal weak var tableView: UITableView!
    private weak var viewModel: PlaylistsDetailViewModel!
    init(model: PlaylistsDetailViewModel) {
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
        guard let viewModel = viewModel else { return UITableViewCell() }
        if let queuePath = viewModel.queueCellPath, indexPath == queuePath {
            let cell = tableView.dequeueReusableCell(withIdentifier: "queue", for: indexPath) as! QueueTableViewCell
            cell.delegate = viewModel
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "media", for: indexPath)

            let model = viewModel.cellViewModel(for: indexPath)
            cell.configure(with: model)
            
            cell.tag = indexPath.row
            viewModel.getImage(for: indexPath, at: .small) { [weak cell] image in
                DispatchQueue.main.async {
                    guard cell?.tag == indexPath.row,
                        let image = image else { return }
                    cell?.imageView?.image = image
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
        return 44
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.unloadQueueCell(false)
    }
}
