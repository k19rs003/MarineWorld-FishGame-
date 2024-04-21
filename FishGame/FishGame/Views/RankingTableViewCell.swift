//
//  RankingTableViewCell.swift
//  MWU
//
//  Created by Abe on R 3/08/07.
//  Copyright © Reiwa 3 Kyushu Sangyo University. All rights reserved.
//

import Foundation
import UIKit

class RankingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var rankingImageView: UIImageView!
    
    
    @IBOutlet weak var view: UIView!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
