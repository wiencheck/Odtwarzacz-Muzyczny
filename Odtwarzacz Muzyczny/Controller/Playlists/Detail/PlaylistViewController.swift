////
////  PlaylistsDetailViewController.swift
////  Musico
////
////  Created by adam.wienconek on 21.08.2018.
////  Copyright © 2018 adam.wienconek. All rights reserved.
////
//
//import UIKit
//import MediaPlayer
//import UIImageColors
//
class PlaylistsDetailViewController: UIViewController {

    var receivedPlaylist: AWConcretePlaylist!

    private var firstLoad = true

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.setEstimatedHeights(false)
        }
    }

    var safeInset: CGFloat = 0 {
        didSet {
            tableManager.topMargin = safeInset
        }
    }

    lazy var viewModel = PlaylistsDetailViewModel(playlist: receivedPlaylist)
    var tableManager: PlaylistDetailTableManager! {
        didSet {
            tableView.setManager(tableManager)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Playlist"
        tableManager = PlaylistDetailTableManager(model: viewModel)

        viewModel.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard firstLoad else { return }
        firstLoad = false
    }
    
}

extension PlaylistsDetailViewController: PlaylistsDetailViewModelDelegate {
    func modelDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData(animated: true)
        }
    }

    func didReloadRow(at path: IndexPath, successfully: Bool) {
        self.tableView.reloadRows(at: [path], with: successfully ? .right : .fade)
    }

    func didFindItem(at index: Int) {
        let path = tableView.indexPath(absoluteRow: index)
        self.tableView.selectRow(at: path, animated: true, scrollPosition: .top)
    }
}
