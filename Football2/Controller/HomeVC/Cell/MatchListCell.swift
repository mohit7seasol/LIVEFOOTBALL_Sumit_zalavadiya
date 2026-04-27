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
    @IBOutlet weak var teamANameLabel: UILabel!
    @IBOutlet weak var teamBNameLabel: UILabel!
    @IBOutlet weak var locationLabel: MarqueeLabel! // Text formate like 'Kishore Bharati Stadium, Kolkata, India'
    @IBOutlet weak var loactionView: CustomView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: CustomView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
