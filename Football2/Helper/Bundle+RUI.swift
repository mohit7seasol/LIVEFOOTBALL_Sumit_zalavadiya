//
//  Bundle+RUI.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//

import Foundation
import UIKit

extension Bundle {
    private static var bundle: Bundle!

    public static func localizedBundle() -> Bundle! {
        if bundle == nil {
            let appLang = UserDefaults.standard.string(forKey: "App_LANGUAGE_KEY") ?? "en"
            let path = Bundle.main.path(forResource: appLang, ofType: "lproj")
            bundle = Bundle(path: path!)
        }

        return bundle
    }

    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "App_LANGUAGE_KEY")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
}
// MARK: - String extension
extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
    }

    func localizeWithFormat(arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
    
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
}

/*
extension Bundle {
    private static var bundle: Bundle!

    public static func localizedBundle() -> Bundle {
        if bundle == nil {
            let appLang = UserDefaults.standard.string(forKey: "App_LANGUAGE_KEY") ?? "en"
            if let path = Bundle.main.path(forResource: appLang, ofType: "lproj"), let localizedBundle = Bundle(path: path) {
                bundle = localizedBundle
            } else {
                bundle = Bundle.main
            }
        }
        return bundle
    }

    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "App_LANGUAGE_KEY")
        if let path = Bundle.main.path(forResource: lang, ofType: "lproj"), let localizedBundle = Bundle(path: path) {
            bundle = localizedBundle
        } else {
            bundle = Bundle.main
        }

        // Force update the app UI
        UIView.appearance().semanticContentAttribute = lang == "ar" ? .forceRightToLeft : .forceLeftToRight
    }
}
*/
