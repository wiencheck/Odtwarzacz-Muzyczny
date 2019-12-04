//
//  SongsMasterController.swift
//  Musico
//
//  Created by adam.wienconek on 17.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistsMasterViewController: UIViewController {
    
    var firstLoad = true
    private var selectedPlaylist: AWConcretePlaylist!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.addRefreshSourcesControl()
            collectionView.emptyMessageTitleText = LocalizedStringKey.emptyViewTitle.localized
            collectionView.emptyMessageDetailText = LocalizedStringKey.emptyViewMessage.localized
        }
    }
        
    let viewModel = PlaylistsMasterViewModel()
    
    var collectionManager: PlaylistsMasterCollectionManager! {
        didSet {
            collectionView.setManager(collectionManager)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = LocalizedStringKey.playlists.localized
        navigationItem.setBackButtonTitle(LocalizedStringKey.playlists.localized)
        
        collectionManager = PlaylistsMasterCollectionManager(model: viewModel)
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            viewModel.fetchPlaylists()
        }
        firstLoad = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard firstLoad else { return }
        //viewModel.fetchPlaylists()
        //viewModel.fetchImages()
        firstLoad = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let spacing: CGFloat = 8
        let cellWidth = view.frame.width / 2 - 3 * spacing
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.5)
        layout.minimumInteritemSpacing = spacing
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PlaylistsDetailViewController {
            destination.receivedPlaylist = selectedPlaylist
        }
    }

}

extension PlaylistsMasterViewController: PlaylistsMasterViewModelDelegate {
    func didUpdateModel() {
        DispatchQueue.main.async {
            self.collectionView.reloadData(animated: true) { _ in
                
            }
        }
    }
    
    func didSelectPlaylist(_ playlist: AWConcretePlaylist) {
        DispatchQueue.main.async {
            self.selectedPlaylist = playlist
            self.performSegue(withIdentifier: "detail", sender: nil)
        }
    }
}
