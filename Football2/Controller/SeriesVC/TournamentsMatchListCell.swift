//
//  TournamentsMatchListCell.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import UIKit
import MarqueeLabel

class TournamentsMatchListCell: UICollectionViewCell {

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var teamAflagImageView: UIImageView!
    @IBOutlet weak var teamANameLabel: MarqueeLabel!
    
    @IBOutlet weak var teamBFlagImageView: UIImageView!
    @IBOutlet weak var teamBnameLabel: MarqueeLabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure cell appearance
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = #colorLiteral(red: 0.937254902, green: 0.9490196078, blue: 0.9607843137, alpha: 1)
        contentView.layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update date view corner radius to be half of its height
        dateView.layer.cornerRadius = dateView.frame.height / 2
    }
}
