//
//  SeriesCountryListCell.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import UIKit

class SeriesCountryListCell: UICollectionViewCell {

    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Configure cell appearance
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = #colorLiteral(red: 0.7568627451, green: 0.8352941176, blue: 0.9176470588, alpha: 1)
        contentView.layer.borderWidth = 1
    }

}
