//
//  TournamentsListCell.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import UIKit

class TournamentsListCell: UICollectionViewCell {
    @IBOutlet weak var tournamentNameLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.cornerRadius = 16
        mainView.layer.masksToBounds = true
        
        gradientLayer.cornerRadius = 16
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        mainView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = mainView.bounds
        CATransaction.commit()
    }
    
    func applyGradient(colors: [CGColor]) {
        gradientLayer.colors = colors
        
        DispatchQueue.main.async {
            self.gradientLayer.frame = self.mainView.bounds
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tournamentNameLabel.text = nil
    }
}
