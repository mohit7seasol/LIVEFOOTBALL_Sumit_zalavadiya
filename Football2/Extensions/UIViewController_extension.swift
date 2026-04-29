//
//  UIViewController_extension.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//


import Foundation
import UIKit
import Toast
import Photos
import MobileCoreServices
import MBProgressHUD

enum AppStoryboards: String {
   case main = "Main"
   case day = "DayWeek"
}

extension UIViewController {
    
    class func instantiate<T: UIViewController>(appStoryboard: AppStoryboards) -> T {
        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
//    MARK: - Add VC as Child
    func add(_ child: UIViewController, frame: CGRect) {
        addChild(child)
        child.view.frame = frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
//    MARK: - Hide Keyboard
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
//    MARK: - Change Language Of App
    
    func reloadVisibleViewControllers() {
//        if let viewControllers = self.navigationController?.viewControllers {
//            for viewController in viewControllers {
//                if let vc = viewController as? LanguageVC {
//                    vc.viewDidLoad() // reload the LanguageVC view
//                } else {
//                    viewController.viewDidLoad() // reload other view controllers
//                }
//            }
//        }
    }

    class public var storyboardID: String {
        return "\(self)"
    }
    
    static public func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    func showAlertDeleteCancel(withTitle title: String, withMessage message:String, completion: @escaping (Bool) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            completion(true)
        }))
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }

    @objc func navigateHidden() ->Void
    {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @objc func navigatebackTwo()
    {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    
    @objc func setHomeDashBoard() {
                
    }
    
    @objc func setModelProfileDashboard()
    {
        
    }

    @objc func setLoginScreen()
    {
        
    }
    
    func convertTimestampToDate(timestampString: String) -> Date? {
        guard let timestamp = Double(timestampString.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)) else {
            return nil
        }
        
        // Create a date from the timestamp (assuming it's in milliseconds)
        let date = Date(timeIntervalSince1970: timestamp / 1000.0)
        return date
    }
    
    func daySuffix(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
    
    func ProgressViewShow(uiView:UIView) {
        
        DispatchQueue.main.async {
            let Indicator = MBProgressHUD.showAdded(to: uiView, animated: true)
            Indicator.label.text = "Loading..."
            uiView.isUserInteractionEnabled = false
            Indicator.show(animated: true)

//          MBProgressHUD.showAdded(to: uiView, animated: true)
        }
    }
    
    func ProgressViewHide(uiView:UIView) {
        
        DispatchQueue.main.async {
            uiView.isUserInteractionEnabled = true
            MBProgressHUD.hide(for:uiView, animated: true)
        }
    }

}

extension UIViewController {
    func showInterAd() {
        if isUserSubscribe() == false {
            // Ensure afterClick is set to 2
            guard afterClick > 0 else {
                // Set default to 2 if afterClick is 0 or not set
                afterClick = 2
                return
            }
            
            adsPlus = adsPlus + 1
            if adsPlus % afterClick == 0 {
                AdsManager.shared.presentInterstitialAd1(vc: self)
            }
        }
    }
    
    func showInterAdSession() {
        DispatchQueue.main.async {
            if isUserSubscribe() == false {
                AdsManager.shared.presentInterstitialAd1(vc: self)
            }
        }
    }
}

extension Date {
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
}

extension DateFormatter {
    static let historyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" 
        return formatter
    }()
    
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
}


extension CMTime {
    var displayString: String {
        let offset = TimeInterval(seconds)
        let numberOfNanosecondsFloat = (offset - TimeInterval(Int(offset))) * 1000.0
        let nanoseconds = Int(numberOfNanosecondsFloat)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return String(format: "%@.%03d", formatter.string(from: offset) ?? "00:00", nanoseconds)
    }
}

extension AVAsset {
    var fullRange: CMTimeRange {
        return CMTimeRange(start: .zero, duration: duration)
    }
    func trimmedComposition(_ range: CMTimeRange) -> AVAsset {
        guard CMTimeRangeEqual(fullRange, range) == false else {return self}

        let composition = AVMutableComposition()
        try? composition.insertTimeRange(range, of: self, at: .zero)

        if let videoTrack = tracks(withMediaType: .video).first {
            composition.tracks.forEach {$0.preferredTransform = videoTrack.preferredTransform}
        }
        return composition
    }
}
