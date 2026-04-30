//
//  TournamentsListCell.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import UIKit
import MarqueeLabel

class TournamentsListCell: UICollectionViewCell {
    @IBOutlet weak var tournamentNameLabel: MarqueeLabel!
    @IBOutlet weak var mainView: UIView!
    
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Cell setup
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // Main view setup
        mainView.layer.cornerRadius = 20
        mainView.layer.masksToBounds = true
        mainView.backgroundColor = .clear
        
        // Gradient layer setup
        gradientLayer.cornerRadius = 20
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Add gradient to main view
        mainView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Ensure mainView fills the cell
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
        // Label setup
        tournamentNameLabel.numberOfLines = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame after layout
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = mainView.bounds
        CATransaction.commit()
    }
    
    func applyGradient(color: UIColor) {
        // Create gradient colors
        gradientLayer.colors = [
            color.cgColor,
            color.withAlphaComponent(0.7).cgColor
        ]
        
        // Ensure gradient frame is set
        gradientLayer.frame = mainView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tournamentNameLabel.text = nil
    }
}
