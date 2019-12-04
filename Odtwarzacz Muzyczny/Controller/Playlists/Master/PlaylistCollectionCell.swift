//
//  PlaylistCollectionCell.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 04/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import UIKit

class PlaylistCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var detailTextLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.af_cancelImageRequest()
    }
    
    func configure(with model: CellViewModel?) {
        guard let model = model else { return }
        textLabel.text = model.title
        detailTextLabel.text = model.detail
        imageView.image = model.mainImage
        if let url = model.imageUrl {
            imageView.af_setImage(withURL: url)
        }
    }
    
}
