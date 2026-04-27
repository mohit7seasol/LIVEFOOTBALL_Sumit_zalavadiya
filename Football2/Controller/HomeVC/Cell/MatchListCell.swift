//
//  MatchListCell.swift
//  Football2
//
//  Created by Mohit Kanpara on 27/04/26.
//

import UIKit
import MarqueeLabel

class MatchListCell: UICollectionViewCell {

    @IBOutlet weak var matchName: MarqueeLabel! // Text formate like 'Paysandu PA vs EC Bahia BA'
    
    @IBOutlet weak var teamAFlagImageView: UIImageView!
    @IBOutlet weak var teamBFlagImageView: UIImageView!
    @IBOutlet weak var teamANameLabel: MarqueeLabel!
    @IBOutlet weak var teamBNameLabel: MarqueeLabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: CustomView!
    @IBOutlet weak var scorLabel: UILabel! // Text formate like '0 - 2'
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
