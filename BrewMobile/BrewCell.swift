//
//  BrewCell.swift
//  BrewMobile
//
//  Created by Agnes Vasarhelyi on 04/01/15.
//  Copyright (c) 2015 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

class BrewCell: UITableViewCell {
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func setTextColorForAllLabels(color: UIColor) {
        minLabel.textColor = color
        statusLabel.textColor = color
    }
}
