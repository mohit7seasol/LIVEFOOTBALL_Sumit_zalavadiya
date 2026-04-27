//
//  GamesVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 05/05/25.
//

import UIKit
import WebKit

class GamesVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var index = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .Games)
        
        if let url = URL(string: gamesURL) {
           let request = URLRequest(url: url)
           webView.load(request)
       } else {
           print("Invalid URL: \(gamesURL)")
           self.view.showToastAtCenter(message: "Could not load URL")
       }
    }
    


}
