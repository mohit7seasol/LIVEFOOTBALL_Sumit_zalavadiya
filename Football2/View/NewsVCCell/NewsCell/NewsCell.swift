//
//  NewsCell.swift
//  Football2
//
//  Created by Parthiv Akbari on 29/04/25.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var iconImg: ImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
