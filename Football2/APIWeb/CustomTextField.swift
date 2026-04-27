//
//  CustomTextField.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//

import Foundation
import UIKit

class CustomTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Disable all default actions (cut, copy, select, all, etc.)
        UIMenuController.shared.menuItems = nil
        
        // Enable only the desired actions
        switch action {
        case #selector(paste(_:)):
            return true
        case #selector(autofillText):
            return true
        default:
            return false
        }
    }
    
    @objc func autofillText() {
        // Handle the Autofill action (replace this with your autofill logic)
        let autofillText = "Autofill Data"
        text = autofillText
    }
}
