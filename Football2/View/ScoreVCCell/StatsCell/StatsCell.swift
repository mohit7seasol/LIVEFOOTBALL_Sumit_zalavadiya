//
//  StatsCell.swift
//  Football2
//
//  Created by Parthiv Akbari on 01/05/25.
//

import UIKit

class StatsCell: UITableViewCell {

    @IBOutlet weak var viewTeam1: CustomView!
    @IBOutlet weak var viewTeam2: CustomView!
    @IBOutlet weak var lblActions: UILabel!
    
    @IBOutlet weak var lblTeam1: UILabel!
    @IBOutlet weak var lblTeam2: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
}
