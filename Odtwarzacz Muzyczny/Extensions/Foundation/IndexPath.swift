//
//  IndexPath.swift
//  Musico
//
//  Created by adam.wienconek on 20.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension IndexPath {
    
    static let first = IndexPath(row: 0, section: 0)
    
    func absoluteRow(in tableView: UITableView) -> Int {
        var _row = 0
        for _section in 0 ..< self.section {
            _row += tableView.numberOfRows(inSection: _section)
        }
        _row += self.row
        return _row
    }
    
}
