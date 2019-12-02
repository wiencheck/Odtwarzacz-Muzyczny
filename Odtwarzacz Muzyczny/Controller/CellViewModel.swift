//
//  TrackCellViewModel.swift
//  Plum
//
//  Created by adam.wienconek on 30.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit
import AlamofireImage

struct CellViewModel {
    /// Main text displayed in label.
    let title: String
    
    let detail: String?
    ///
    let secondaryDetail: String?
    
    let detailSeparator: String?
    
    let mainImage: UIImage
    
    let imageUrl: URL?
        
    init(title: String, detail: String?, secondaryDetail: String? = nil, rightDetail: String? = nil, mainImage: UIImage, secondaryImage: UIImage? = nil, imageUrl: URL? = nil, detailSeparator: String? = "•") {
        self.title = title
        self.detail = detail
        self.secondaryDetail = secondaryDetail
        self.mainImage = mainImage
        self.imageUrl = imageUrl
        self.detailSeparator = detailSeparator
    }
}

extension UITableViewCell {
    func configure(with model: CellViewModel?) {
        guard let model = model else { return }
        textLabel?.text = model.title
        
        var detail = model.detail
        if let d = detail, let secondary = model.secondaryDetail {
            detail = [d, secondary].joined(separator: model.detailSeparator ?? "")
        }
        detailTextLabel?.text = detail
        imageView?.image = model.mainImage
        if let url = model.imageUrl {
            imageView?.af_setImage(withURL: url)
        }
    }
}
