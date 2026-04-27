import Foundation
import UIKit

@IBDesignable
class CustomView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            gradientLayer.cornerRadius = cornerRadius
            dashedBorderLayer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 4 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    // Gradient Colors
    @IBInspectable var startColor: UIColor = .clear {
        didSet {
            updateGradientColors()
        }
    }

    @IBInspectable var endColor: UIColor = .clear {
        didSet {
            updateGradientColors()
        }
    }

    // Gradient direction: 0 = horizontal, 1 = vertical
    @IBInspectable var isVertical: Bool = false {
        didSet {
            updateGradientDirection()
        }
    }

    // Dashed Border Properties
    @IBInspectable var dashBorderColor: UIColor = .clear {
        didSet {
            updateDashBorder()
        }
    }
    
    @IBInspectable var dashBorderWidth: CGFloat = 1 {
        didSet {
            updateDashBorder()
        }
    }
    
    @IBInspectable var dashPattern: [NSNumber] = [6, 3] { // Dash length and gap
        didSet {
            updateDashBorder()
        }
    }

    private let gradientLayer = CAGradientLayer()
    private let dashedBorderLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Custom initialization code
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        
        // Shadow setup
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        
        // Gradient setup
        gradientLayer.cornerRadius = cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradientColors()
        updateGradientDirection()

        // Dashed border setup
        dashedBorderLayer.strokeColor = dashBorderColor.cgColor
        dashedBorderLayer.fillColor = nil
        dashedBorderLayer.lineDashPattern = dashPattern
        dashedBorderLayer.lineWidth = dashBorderWidth
        dashedBorderLayer.frame = bounds
        layer.addSublayer(dashedBorderLayer)
    }

    private func updateGradientColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }

    private func updateGradientDirection() {
        if isVertical {
            // Vertical gradient
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        } else {
            // Horizontal gradient
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }
    }

    private func updateDashBorder() {
        let dashPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        dashedBorderLayer.path = dashPath.cgPath
        dashedBorderLayer.strokeColor = dashBorderColor.cgColor
        dashedBorderLayer.lineDashPattern = dashPattern
        dashedBorderLayer.lineWidth = dashBorderWidth
        dashedBorderLayer.frame = bounds
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateDashBorder() // Ensure the dashed border is updated when layout changes
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
}
