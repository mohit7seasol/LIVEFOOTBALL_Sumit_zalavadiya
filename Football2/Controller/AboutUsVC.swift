//
//  AboutUsVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit

class AboutUsVC: UIViewController {

    @IBOutlet weak var versionLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logAnalyticAction(title: "", status: .AboutUs)
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.versionLbl.text = "\(APPNAME) \t Version: \(version)"
        }
        
    }
    

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
