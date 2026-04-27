//
//  SettingsVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var subLbl: UILabel!
    @IBOutlet weak var langLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var inviteLbl: UILabel!
    @IBOutlet weak var privacyLbl: UILabel!
    @IBOutlet weak var termsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .Settings)
        self.appNameLbl.text = APPNAME
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subLbl.text = "Track Every Goal".localized()
        self.langLbl.text = "Language".localized()
        self.aboutLbl.text = "About Us".localized()
        self.rateLbl.text = "Rate App".localized()
        self.inviteLbl.text = "Invite Friends".localized()
        self.privacyLbl.text = "Privacy Policy".localized()
        self.termsLbl.text = "Terms & Conditions".localized()
    }
    
    @IBAction func langTapped(_ sender: UIButton) {
        isFromSettingsVC = true
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func aboutTapped(_ sender: UIButton) {
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func rateTapped(_ sender: UIButton) {
        if let url = URL(string: REVIEW_LINK) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        let textToShare = "Check out this awesome app!"
        if let appURL = URL(string: "https://apps.apple.com/app/id\(APP_ID)") {
            let activityViewController = UIActivityViewController(activityItems: [textToShare, appURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            print("Invalid URL")
        }
    }
    
    @IBAction func privacyTapped(_ sender: UIButton) {
        logAnalyticAction(title: "", status: .PrivacyPolicy)
        if let url = URL(string: "\(privacyPolicy)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func termsTapped(_ sender: UIButton) {
        logAnalyticAction(title: "", status: .TermsOfService)
        if let url = URL(string: "\(termsOfUse)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}
