//
//  LangCell.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit

class LangCell: UITableViewCell {

    @IBOutlet weak var customView: CustomView!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var langLbl: UILabel!
    @IBOutlet weak var checkImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
