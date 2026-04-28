//
//  HeadToHeadCell.swift
//  Football
//
//  Created by Mohit Kanpara on 11/04/26.
//

import UIKit
import MarqueeLabel

class HeadToHeadCell: UITableViewCell {

    @IBOutlet weak var lblTeam1Name: MarqueeLabel!
    @IBOutlet weak var lblTeam1homeScore: MarqueeLabel!

    @IBOutlet weak var lblTeam2lblName: MarqueeLabel!
    @IBOutlet weak var lblTeam2awayScore: MarqueeLabel!

    @IBOutlet weak var imgTeam1Flag: UIImageView!
    @IBOutlet weak var imgTeam2Flag: UIImageView!
    
    
    @IBOutlet weak var lblTeam1Date: MarqueeLabel!
    @IBOutlet weak var lblTeam2Date: MarqueeLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
