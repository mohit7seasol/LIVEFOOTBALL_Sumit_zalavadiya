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
        showRateDialog()
    }
    
    func showRateDialog() {
        let alert = UIAlertController(title: "Do you like our App?".localized(),
                                      message: "Help us improve it by answering this quick poll.".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No ❌".localized(), style: .default))
        alert.addAction(UIAlertAction(title: "Yes 👍".localized(), style: .default) { _ in
            self.rateApp()
        })
        self.present(alert, animated: true)
    }
    
    func rateApp() {
        if let scene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func removeSelection() {
        self.homeImg.image = UIImage(named: "HomeUnSelect")
        self.upcomingImg.image = UIImage(named: "UpcomingUnSelect")
        self.finishedImg.image = UIImage(named: "FinishedUnSelect")
        self.seriesImg.image = UIImage(named: "SeriesUnSelect")
        self.gamesImg.image = UIImage(named: "GamesUnSelect")
        self.topViewHeight.constant = 0
        self.centerViewTop.constant = 0
    }
    
    
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
