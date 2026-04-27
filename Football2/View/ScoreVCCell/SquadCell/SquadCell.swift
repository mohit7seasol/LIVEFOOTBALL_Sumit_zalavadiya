//
//  SquadCell.swift
//  Football2
//
//  Created by Parthiv Akbari on 01/05/25.
//

import UIKit

class SquadCell: UITableViewCell {

    @IBOutlet weak var team1PlayerImg: UIImageView!
    @IBOutlet weak var team1PlayerNameLbl: UILabel!
    @IBOutlet weak var team1PlayerRoleLbl: UILabel!
    @IBOutlet weak var team2PlayerImg: UIImageView!
    @IBOutlet weak var team2PlayerNameLbl: UILabel!
    @IBOutlet weak var team2PlayerRoleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
