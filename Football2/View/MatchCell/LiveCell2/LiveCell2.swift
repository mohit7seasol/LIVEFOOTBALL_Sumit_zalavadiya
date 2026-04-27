//
//  LiveCell2.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import MarqueeLabel

class LiveCell2: UICollectionViewCell {

    @IBOutlet weak var lblTitle: MarqueeLabel!
    @IBOutlet weak var lblDate: MarqueeLabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var lblTeam1: UILabel!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var lblTeam2: UILabel!
    @IBOutlet weak var statusLbl: MarqueeLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
