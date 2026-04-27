//
//  HomeVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class HomeVC: UIViewController {
    @IBOutlet weak var viewForNative: UIView!
    @IBOutlet weak var matchListCollection: UICollectionView!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var finishedButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var currentMonthLabel: UILabel! // Text formate : 'December 2025'
    
    
    var index = -1 // Do not removed 
    
    var isAscending: Bool = true
    var isLiveAvailable: Bool = true
    var matchesUpcoming: [MatchUpcoming] = []
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var newsData: News?
    var newsResults: [Result] = []
    var selectedPosts: [Post] = []
    var selectedCategoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .Home)
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ProgressViewShow(uiView: self.view)
    }
    
    func subscribe() {
        showSkeletonView()
        if Subscribe.get() == false {
            self.googleNativeAds.loadInlineNativeAds(self) { nativeAdsTemp in
                print(" Home...Load Native ....")
                self.viewForNative.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.hideSkeletonView()
                    self.googleNativeAds.showAdsView6(nativeAd: nativeAdsTemp, view: self.viewForNative)
                }
            }
            
            self.googleNativeAds.failAds(self) { fail in
                print(" Home...Native fail....")
                self.viewForNative.isHidden = true
            }
            
        } else {
            self.hideSkeletonView()
            viewForNative.isHidden = true
        }
    }
    
    func showSkeletonView() {
        if let adView = Bundle.main.loadNibNamed("SkeletonCustomView3", owner: self, options: nil)?.first as? SkeletonCustomView3 {
            // Add the custom UIView to the adContainerView
            self.viewForNative.addSubview(adView)
            
            // Set constraints to make sure the adView fills the adContainerView
            adView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: self.viewForNative.topAnchor),
                adView.leadingAnchor.constraint(equalTo: self.viewForNative.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: self.viewForNative.trailingAnchor),
                adView.bottomAnchor.constraint(equalTo: self.viewForNative.bottomAnchor)
            ])
            adView.view1.showAnimatedGradientSkeleton()
            adView.view2.showAnimatedGradientSkeleton()
            adView.view3.showAnimatedGradientSkeleton()
            adView.view4.showAnimatedGradientSkeleton()
            adView.view5.showAnimatedGradientSkeleton()
            
        }
    }
    
    func hideSkeletonView() {
        for subview in self.viewForNative.subviews {
            if let adView = subview as? SkeletonCustomView3 {
                adView.removeFromSuperview()
            }
        }
    }
}

// MARK: - Button Actions
extension HomeVC {
    @IBAction func todayButtonTap(_ sender: UIButton) {
    }
    
    @IBAction func liveButtonTap(_ sender: UIButton) {
    }
    
    @IBAction func upcomingButtonTap(_ sender: UIButton) {
    }
    
    @IBAction func finishedButtonTap(_ sender: UIButton) {
    }
    
}
// MARK: - Live Match API Call
extension HomeVC {
}

//MARK: - Upcoming API Call
extension HomeVC {

}

// MARK: - News API Call
extension HomeVC {
    
}
