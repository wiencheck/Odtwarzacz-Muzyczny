//
//  SongsMasterController.swift
//  Musico
//
//  Created by adam.wienconek on 17.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SongsViewController: UIViewController {
    
    private var firstLoad = true
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .none
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.shouldDisplayEmptyMessage = true
            tableView.emptyMessageTitleText = LocalizedStringKey.emptyViewTitle.localized
            tableView.emptyMessageDetailText = LocalizedStringKey.emptyViewMessage.localized
            tableView.addRefreshSourcesControl()
            tableView.setEstimatedHeights(false)
        }
    }
    
    lazy var viewModel = SongsViewModel()
    
    var tableManager: SongsTableManager! {
        didSet {
            tableView.setManager(tableManager)
        }
    }
    var indexView: AWIndexView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Songs"
        navigationItem.title = LocalizedStringKey.songs.localized
        navigationItem.setBackButtonTitle(LocalizedStringKey.songs.localized)

        tableManager = SongsTableManager(model: viewModel)
        addIndexView()
        
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard firstLoad else { return }
        viewModel.fetchTracks()
        firstLoad = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indexView.flash()
    }

}

extension SongsViewController: AWIndexViewDelegate {
    func indexViewDidChange(indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    func numberOfItems(in section: Int) -> Int {
        return viewModel.numberOfRows(for: section)
    }
    
    var sectionIndexes: [String] {
        return viewModel.sectionIndexes
    }
}

extension SongsViewController: SongsViewModelDelegate {
    func didUpdateModel() {
        DispatchQueue.main.async {
            self.tableView.reloadData(animated: true) { _ in
                self.indexView.setup()
            }
        }
    }
    
    func didReloadRow(at path: IndexPath, successfully: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [path], with: successfully ? .right : .fade)
        }
    }
}
