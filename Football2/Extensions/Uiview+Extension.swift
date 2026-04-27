//
//  Uiview+Extension.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//

import Foundation
import UIKit
import Toast_Swift

extension UIView {
    
    public func showToastAtBottom(message: String, duration: TimeInterval = 3.0) {
        var style = ToastStyle()
        style.messageColor = .white
        style.backgroundColor = .black
        self.makeToast(message, duration: duration, position: .bottom, style: style)
    }
    
    public func showToastAtTop(message: String) {
        var style = ToastStyle()
        style.messageColor = .white
        style.backgroundColor = .black
        self.makeToast(message, duration: 3.0, position: .top, style: style)
    }
    
    public func showToastAtCenter(message: String) {
        var style = ToastStyle()
        style.messageColor = .white
        style.backgroundColor = .black
        self.makeToast(message, duration: 3.0, position: .center, style: style)
    }
    
    public func addCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    public func applyBorder(_ width: CGFloat, borderColor: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
    
    public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    public func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
    
    public func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
    
    public func addLeftBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }
    
    public func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        addSubview(border)
    }
    
    public func addShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    //    public func applyViewGradient(colors : [UIColor]) {
    //        let image = UIImage.gradientImageWith(size: CGSize(width: self.bounds.width, height: self.bounds.height), colors: colors)
    //        self.backgroundColor = UIColor.init(patternImage: image!)
    //    }
    
    public func addShadowToSpecificCorner(top: Bool, left: Bool, bottom: Bool, right: Bool, shadowRadius: CGFloat = 1.0) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.10
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if !top {
            y+=(shadowRadius+1)
        }
        if !bottom {
            viewHeight-=(shadowRadius+1)
        }
        if !left {
            x+=(shadowRadius+1)
        }
        if !right {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        
        path.close()
        self.layer.shadowPath = path.cgPath
    }
    
    public func addShadow() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 6
    }
    
    
    func applyGradient(colors: [CGColor], locations: [NSNumber]?) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.frame = frame
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradient(view: UIView)
    {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.black,UIColor.white]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = view.layer.frame
        view.layer.insertSublayer(gradient, at: 0)
    }
    /*
     func addInnerShadow() {
     // Create a shadow layer
     let shadowLayer = CALayer()
     shadowLayer.frame = self.bounds
     
     // Define the shadow properties
     shadowLayer.shadowColor = UIColor(hex: "#353535")?.cgColor
     shadowLayer.shadowOffset = CGSize(width: -1.44, height: -1.44)
     shadowLayer.shadowOpacity = 0.7
     shadowLayer.shadowRadius = 2.88
     
     // Create a path that covers the entire view and then cuts out the inner part
     let path = UIBezierPath(rect: self.bounds.insetBy(dx: -10, dy: -10))
     let cutout = UIBezierPath(rect: self.bounds).reversing()
     path.append(cutout)
     
     shadowLayer.shadowPath = path.cgPath
     shadowLayer.masksToBounds = true
     
     // Add the shadow layer to the view's layer
     self.layer.addSublayer(shadowLayer)
     }
     */
    
    func addInnerShadow(xOffset: CGFloat, yOffset: CGFloat, blur: CGFloat, shadowColor: UIColor, opacity: Float) {
        
        let shadowLayer = CALayer()
        shadowLayer.name = "InnerShadow"
        shadowLayer.frame = bounds
        
        // Shadow properties
        let path = UIBezierPath(rect: shadowLayer.bounds.insetBy(dx: -blur * 2, dy: -blur * 2))
        let cutout = UIBezierPath(rect: shadowLayer.bounds).reversing()
        path.append(cutout)
        
        shadowLayer.shadowPath = path.cgPath
        shadowLayer.masksToBounds = true
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowOffset = CGSize(width: xOffset, height: yOffset)
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = blur
        shadowLayer.cornerRadius = layer.cornerRadius
        
        layer.addSublayer(shadowLayer)
    }
    
    func addDropShadow(xOffset: CGFloat, yOffset: CGFloat, blur: CGFloat, shadowColor: UIColor, opacity: Float) {
        
        let shadowLayer = CALayer()
        shadowLayer.name = "DropShadow"
        shadowLayer.frame = bounds
        
        // Shadow properties
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowOffset = CGSize(width: xOffset, height: yOffset)
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = blur
        shadowLayer.shadowPath = UIBezierPath(rect: shadowLayer.bounds).cgPath
        shadowLayer.masksToBounds = false
        shadowLayer.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func applyBottomCornerRadius(cornerRadius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
    
    func applyTopCornerRadius(cornerRadius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
    
    //MARK: - GradientBackground For UIView
        func setGradientBackground() {
            // Create a gradient layer
            let gradientLayer = CAGradientLayer()
            
            // Define the start and end points of the gradient
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            // Define the colors for the gradient
            gradientLayer.colors = [
                UIColor(red: 1.00, green: 0.61, blue: 0.22, alpha: 1.0).cgColor, // #FF9D37
                UIColor(red: 0.91, green: 0.50, blue: 0.07, alpha: 1.0).cgColor  // #E77F12
            ]
            
            // Define the locations of the colors
            gradientLayer.locations = [0.0133, 0.9726]
            
            // Set the frame of the gradient layer to match the view's bounds
            gradientLayer.frame = self.bounds.offsetBy(dx: 0, dy: 0)
            
            // Add the gradient layer to the view's layer
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        //MARK: - Shadow For UIView
        func applyRoundedCornersWithShadow(cornerRadius: CGFloat = 10, shadowColor: UIColor = .black, shadowOpacity: Float = 0.2, shadowOffset: CGSize = CGSize(width: 1, height: 1), shadowRadius: CGFloat = 4) {
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = false
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOpacity = shadowOpacity
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowRadius = shadowRadius
        }
        
        func applyRoundedCornersWithBorder(cornerRadius: CGFloat = 10, borderWidth: CGFloat = 1.0, borderColor: UIColor = .black) {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor.cgColor
        }
    
    func applyCornerRadiusToSpecificCorners(corners: UIRectCorner, radius: CGFloat) {
            let path = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
        self.layer.mask = mask
        }
}



extension Int {
    func toDateString(format: String = "dd MMM yyyy") -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
