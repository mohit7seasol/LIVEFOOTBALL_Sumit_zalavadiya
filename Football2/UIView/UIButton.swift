
import Foundation
import UIKit

@IBDesignable
class CustomButton: UIButton {

    // MARK: - IBInspectable properties
    /// Renders vertical gradient if true else horizontal
    @IBInspectable public var isVertical: Bool = true {
        didSet {
            updateUI()
        }
    }

    /// Start color of the gradient
    @IBInspectable public var startColor: UIColor = .clear {
        didSet {
            updateUI()
        }
    }

    /// End color of the gradient
    @IBInspectable public var endColor: UIColor = .clear {
        didSet {
            updateUI()
        }
    }

    /// Border color of the view
    @IBInspectable public var borderColor: UIColor? = nil {
        didSet {
            updateUI()
        }
    }

    /// Border width of the view
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            updateUI()
        }
    }

    /// Corner radius of the view
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            updateUI()
        }
    }

    /// Shadow color of the view
    @IBInspectable public var shadowColor: UIColor = .black {
        didSet {
            updateUI()
        }
    }

    /// Shadow opacity of the view
    @IBInspectable public var shadowOpacity: Float = 0.5 {
        didSet {
            updateUI()
        }
    }

    /// Shadow offset of the view
    @IBInspectable public var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            updateUI()
        }
    }

    /// Shadow radius of the view
    @IBInspectable public var shadowRadius: CGFloat = 4 {
        didSet {
            updateUI()
        }
    }

    // MARK: - Variables

    /// Closure is called on click event of the button
    public var onClick = { () }

    private var gradientlayer = CAGradientLayer()

    // MARK: - init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    // MARK: - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }

    // MARK: - UI Setup
    private func setupUI() {
        gradientlayer = CAGradientLayer()
        updateUI()
        layer.addSublayer(gradientlayer)
    }

    // MARK: - Update frame
    private func updateFrame() {
        gradientlayer.frame = bounds
    }

    // MARK: - Update UI
    private func updateUI() {
        addTarget(self, action: #selector(clickAction(button:)), for: UIControl.Event.touchUpInside)
        gradientlayer.colors = [startColor.cgColor, endColor.cgColor]
        if isVertical {
            gradientlayer.startPoint = CGPoint(x: 0, y: 0)
            gradientlayer.endPoint = CGPoint(x: 0, y: 1)
        } else {
            gradientlayer.startPoint = CGPoint(x: 0, y: 0)
            gradientlayer.endPoint = CGPoint(x: 1, y: 0)
        }
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor ?? tintColor.cgColor
        if cornerRadius > 0 {
            layer.masksToBounds = true
        }
        
        // Shadow properties
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false

        updateFrame()
    }

    // MARK: - On Click
    @objc private func clickAction(button: UIButton) {
        onClick()
    }
}
