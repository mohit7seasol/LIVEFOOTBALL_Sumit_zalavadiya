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
        contentView.layer.borderColor = #colorLiteral(red: 0.1294117647, green: 0.2117647059, blue: 0.2509803922, alpha: 1)
        contentView.layer.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.2117647059, blue: 0.2509803922, alpha: 1)
        contentView.layer.borderWidth = 1
    }

}
