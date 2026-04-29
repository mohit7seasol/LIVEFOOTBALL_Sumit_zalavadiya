//
//  TournamentsMatchListCell.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import UIKit
import MarqueeLabel

class TournamentsMatchListCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var teamAflagImageView: UIImageView!
    @IBOutlet weak var teamANameLabel: MarqueeLabel!
    
    @IBOutlet weak var teamBFlagImageView: UIImageView!
    @IBOutlet weak var teamBnameLabel: MarqueeLabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
