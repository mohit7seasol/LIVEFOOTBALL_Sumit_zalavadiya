//
//  BaseVC.swift
//  LiveCricket2
//
//  Created by Parthiv Akbari on 16/12/24.
//

import UIKit
import GoogleMobileAds
import SafariServices

class BaseVC: UIViewController, UIGestureRecognizerDelegate {

    
    var handleDisablingPopGesture = false {
        didSet {
            if handleDisablingPopGesture == true {
                self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            } else {
                self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            }
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if handleDisablingPopGesture == true {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if handleDisablingPopGesture == true {
            
        }
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if handleDisablingPopGesture == true {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if handleDisablingPopGesture == true, gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return false
        }
        // add whatever logic you would otherwise have
        return true
    }
  
    func textSize(font: UIFont, text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size.width
    }

    func convertTimestamp(_ timestamp: Int) -> (formattedDate: String, formattedTime: String, formattedDifference: String) {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        // Format the Date to "Saturday, 22 Jun"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMM"
        let formattedDate = dateFormatter.string(from: date)
        
        // Format the Date to "05:30AM"
        dateFormatter.dateFormat = "hh:mma"
        let formattedTime = dateFormatter.string(from: date)
        
        // Calculate the time difference from the current date and time
        let currentDate = Date()
        let difference = date.timeIntervalSince(currentDate)
        let differenceHours = Int(difference) / 3600
        let differenceMinutes = (Int(difference) % 3600) / 60
        
        let formattedDifference = String(format: "%02d:%02d", differenceHours, differenceMinutes)
        
        return (formattedDate, formattedTime, formattedDifference)
    }
    
    
}
extension UIViewController {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
