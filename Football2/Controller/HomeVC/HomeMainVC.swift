//
//  HomeMainVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import SideMenu
import StoreKit

class HomeMainVC: UIViewController {

    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var centerViewTop: NSLayoutConstraint!
    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var tabBarView: CustomView!
    @IBOutlet weak var upcomingImg: UIImageView!
    @IBOutlet weak var homeImg: UIImageView!
    @IBOutlet weak var finishedImg: UIImageView!
    @IBOutlet weak var seriesImg: UIImageView!
    @IBOutlet weak var gamesImg: UIImageView!
    
    private weak var pagerVc: HomePagerVC?
    
    // UserDefaults keys
    private let kHasUserRespondedToRatePopup = "RatePopupResponded"
    private let kHasUserRatedApp = "RateDone"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appNameLbl.text = APPNAME
        self.tabBarView.layer.cornerRadius = 14
        self.tabBarView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.removeSelection()
        self.topViewHeight.constant = 35
        self.centerViewTop.constant = 35
        self.homeImg.image = UIImage(named: "HomeSelect")
        pagerVc?.moveToPage(index: 0, animated: false)
        
        // Show rate screen after a short delay to ensure UI is loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showRateScreen()
        }
    }
    
    func showRateScreen() {
        // Check if user has already rated the app
        if hasUserRatedApp() {
            print("User has already rated the app")
            return
        }
        
        let alert = UIAlertController.init(
            title: "Do you like our App?".localized(),
            message: "Help us improve it by answering this quick poll.".localized(),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction.init(title: "No ❌".localized(), style: .default, handler: { _ in
            // User said No - mark as responded so popup won't show again
            print("User selected No - rate popup will not appear again")
        }))
        
        alert.addAction(UIAlertAction.init(title: "Yes 👍".localized(), style: .default, handler: { _ in
            // User said Yes - mark as responded and show rate screen
            self.markRatePopupAsResponded()
            print("User selected Yes - showing rate popup")
            self.rateApp()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {
            // Request review from Apple
            SKStoreReviewController.requestReview()
            // Mark that user has been shown the review prompt
            setRateDone(status: true)
        } else {
            if let appStoreURL = URL(string: AppStoreLink) {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: { success in
                    if success {
                        self.setRateDone(status: true)
                    }
                })
            } else {
                let appStoreURL = URL(string: AppStoreLink)
                UIApplication.shared.openURL(appStoreURL!)
            }
        }
    }
    
    // MARK: - UserDefaults Management
    
    /// Mark that user has responded to the rate popup (either Yes or No)
    func markRatePopupAsResponded() {
        UserDefaults.standard.set(true, forKey: kHasUserRespondedToRatePopup)
        UserDefaults.standard.synchronize()
    }
    
    /// Check if user has already responded to the rate popup
    func hasUserRespondedToRatePopup() -> Bool {
        return UserDefaults.standard.bool(forKey: kHasUserRespondedToRatePopup)
    }
    
    /// Mark that user has rated the app (or been prompted to rate)
    func setRateDone(status: Bool) {
        UserDefaults.standard.set(status, forKey: kHasUserRatedApp)
        UserDefaults.standard.synchronize()
    }
    
    /// Check if user has already rated the app
    func hasUserRatedApp() -> Bool {
        return UserDefaults.standard.bool(forKey: kHasUserRatedApp)
    }
    
    // MARK: - UI Updates
    
    func removeSelection() {
        self.homeImg.image = UIImage(named: "HomeUnSelect")
        self.upcomingImg.image = UIImage(named: "UpcomingUnSelect")
        self.finishedImg.image = UIImage(named: "FinishedUnSelect")
        self.seriesImg.image = UIImage(named: "SeriesUnSelect")
        self.gamesImg.image = UIImage(named: "GamesUnSelect")
        self.topViewHeight.constant = 0
        self.centerViewTop.constant = 0
    }
    
    // MARK: - Button Actions
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SettingsVC") as! SettingsVC
        var navigation = SideMenuNavigationController(rootViewController: vc)
        navigation.navigationBar.isHidden = true
        navigation.leftSide = true
        navigation.menuWidth = 300
        
        self.present(navigation, animated: true, completion: nil)
    }
    
    @IBAction func homeTapped(_ sender: UIButton) {
        self.removeSelection()
        self.topViewHeight.constant = 35
        self.centerViewTop.constant = 35
        self.homeImg.image = UIImage(named: "HomeSelect")
        pagerVc?.moveToPage(index: 0, animated: false)
    }
    
    @IBAction func upcomingTapped(_ sender: UIButton) {
        self.removeSelection()
        self.topViewHeight.constant = 35
        self.centerViewTop.constant = 35
        self.upcomingImg.image = UIImage(named: "UpcomingSelect")
        pagerVc?.moveToPage(index: 1, animated: false)
    }
    
    @IBAction func finishedTapped(_ sender: UIButton) {
        self.removeSelection()
        self.topViewHeight.constant = 35
        self.centerViewTop.constant = 35
        self.finishedImg.image = UIImage(named: "FinishedSelect")
        pagerVc?.moveToPage(index: 2, animated: false)
    }
    
    @IBAction func seriesTapped(_ sender: UIButton) {
        self.removeSelection()
        self.topViewHeight.constant = 35
        self.centerViewTop.constant = 35
        self.seriesImg.image = UIImage(named: "SeriesSelect")
        pagerVc?.moveToPage(index: 2, animated: false)
    }
    
    @IBAction func gamesTapped(_ sender: UIButton) {
        self.removeSelection()
        self.topViewHeight.constant = 0
        self.centerViewTop.constant = 0
        self.gamesImg.image = UIImage(named: "GamesSelect")
        pagerVc?.moveToPage(index: 4, animated: false)
    }
}

// MARK: - HomePickDelegate
extension HomeMainVC: HomePickDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? HomePagerVC {
            pagerVc = pageViewController
            pagerVc?.tabDelegate = self
        }
    }
    
    func didPickItem(currentItem: Int) {
        if currentItem == 0 {
            pagerVc?.moveToPage(index: 0, animated: false)
        } else if currentItem == 1 {
            pagerVc?.moveToPage(index: 1, animated: false)
        } else if currentItem == 2 {
            pagerVc?.moveToPage(index: 2, animated: false)
        } else if currentItem == 3 {
            pagerVc?.moveToPage(index: 3, animated: false)
        } else if currentItem == 4 {
            pagerVc?.moveToPage(index: 4, animated: false)
        }
    }
}
