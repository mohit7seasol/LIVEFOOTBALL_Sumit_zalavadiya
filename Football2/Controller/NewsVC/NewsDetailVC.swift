//
//  NewsDetailVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 29/04/25.
//

import UIKit

class NewsDetailVC: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var newsImg: UIImageView!
    @IBOutlet weak var newsTitleLbl: UILabel!
    @IBOutlet weak var viewForNative: UIView!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var newsArticleLbl: UILabel!
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    // Receive data from NewsListVC
    var selectedNews: NewsItem?
    var currentCategory = "News"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set category title
        self.titleLbl.text = self.currentCategory
        
        // Set news data
        if let news = selectedNews {
            self.newsTitleLbl.text = news.title
            self.detailLbl.text = news.subDesc
            self.newsArticleLbl.text = news.article.replacingOccurrences(of: "\n+", with: "\n\n", options: .regularExpression)
            
            // Load image
            if let imageURL = URL(string: news.imageUrl) {
                self.newsImg.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "DefaultNews2"))
            }
        }
        
        subscribe()
    }
    
    func subscribe() {
        showSkeletonView()
        if Subscribe.get() == false {
            self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                print(" Home...Load Native ....")
                self.viewForNative.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.hideSkeletonView()
                    self.googleNativeAds.showAdsView8(nativeAd: nativeAdsTemp, view: self.viewForNative)
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
            self.viewForNative.addSubview(adView)
            
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
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
