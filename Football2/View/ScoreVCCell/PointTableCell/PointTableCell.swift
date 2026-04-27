//
//  PointTableCell.swift
//  Football2
//
//  Created by Parthiv Akbari on 01/05/25.
//

import UIKit

class PointTableCell: UITableViewCell {

    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblM: UILabel!
    @IBOutlet weak var lblW: UILabel!
    @IBOutlet weak var lblL: UILabel!
    @IBOutlet weak var lblD: UILabel!
    @IBOutlet weak var lblPTS: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
