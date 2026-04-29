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
    @IBOutlet weak var newsDateLbl: UILabel!
    @IBOutlet weak var newsTitleLbl: UILabel!
    @IBOutlet weak var newsDescTextView: UITextView!
    @IBOutlet weak var viewForNative: UIView!
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var selectedNews: Post?
    var currentCategory = "News"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLbl.text = self.currentCategory
        
        self.newsTitleLbl.text = selectedNews?.title ?? ""
        self.newsDescTextView.text = selectedNews?.special ?? ""
        
        if let imageURL = URL(string: selectedNews?.media.thumbSrc ?? "") {
            self.newsImg.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "DefaultNews2"))
        }
        
        let timestampString = String(selectedNews!.updatedAt)
        if let date = convertTimestampToDate(timestampString: timestampString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d'\(daySuffix(for: date))' MMM yyyy, h:mm a"
            let formattedDate = dateFormatter.string(from: date)
            self.newsDateLbl.text = formattedDate
            print("Formatted Date: \(formattedDate)")
        } else {
            self.newsDateLbl.text = timestampString
            print("Invalid timestamp format")
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
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
