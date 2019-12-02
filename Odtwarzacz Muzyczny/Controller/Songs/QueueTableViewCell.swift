//
//  QueueTableViewCell.swift
//  Musico
//
//  Created by adam.wienconek on 05.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

protocol QueueCellDelegate: class {
    func queueCell(playNowPressed in: QueueTableViewCell)
    func queueCell(playNextressed in: QueueTableViewCell)
    func queueCell(playLastPressed in: QueueTableViewCell)
}

class QueueTableViewCell: UITableViewCell {
    @IBOutlet private weak var nowButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var lastButton: UIButton!
    
    weak var delegate: QueueCellDelegate?
    
    @IBAction private func nowButtonPressed(_ sender: UIButton) {
        delegate?.queueCell(playNowPressed: self)
    }
    
    @IBAction private func nextButtonPressed(_ sender: UIButton) {
        delegate?.queueCell(playNextressed: self)
    }
    
    @IBAction private func lastButtonPressed(_ sender: UIButton) {
        delegate?.queueCell(playLastPressed: self)
    }
}
