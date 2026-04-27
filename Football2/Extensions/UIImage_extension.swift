//
//  UIImage_extension.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//

import Foundation
import UIKit
import ImageIO
import AVFoundation
import Photos
import MobileCoreServices
import PhotosUI

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func animatedImage(withAnimatedGIFData data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        var images: [UIImage] = []
        var duration: TimeInterval = 0
        
        for i in 0..<CGImageSourceGetCount(source) {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                
                // Add frame duration
                let frameDuration = UIImage.frameDuration(for: source, index: i)
                duration += frameDuration
            }
        }
        return UIImage.animatedImage(with: images, duration: duration)
    }
    
    static func frameDuration(for source: CGImageSource, index: Int) -> TimeInterval {
        let defaultFrameDuration = 0.1
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
              let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double else {
            return defaultFrameDuration
        }
        return delayTime > 0 ? delayTime : defaultFrameDuration
    }
}
