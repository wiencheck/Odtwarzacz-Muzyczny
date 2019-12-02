//
//  SongTableViewCell.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 02/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import UIKit
import AlamofireImage

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    override var textLabel: UILabel? {
        return titleLabel
    }
    
    @IBOutlet private weak var detailLabel: UILabel!
    override var detailTextLabel: UILabel? {
        return detailLabel
    }
    
    @IBOutlet private weak var imageV: UIImageView!
    override var imageView: UIImageView? {
        return imageV
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageV.af_cancelImageRequest()
    }
    
}


