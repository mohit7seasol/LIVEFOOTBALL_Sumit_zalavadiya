//
//  MatchDateCell.swift
//  Football2
//
//  Created by Mohit Kanpara on 27/04/26.
//

import UIKit

class MatchDateCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView! // if cell selected then set background '#16C924' color code set '#566D74'
    @IBOutlet weak var dayNameLabel: UILabel! // Text Formate like 'TUE'
    @IBOutlet weak var dateLabel: UILabel! // Text Formate like '20'
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
