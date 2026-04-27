//
//  IntroVC4.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import Lottie

class IntroVC4: UIViewController {

    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var bottomLbl: UILabel!
    @IBOutlet weak var nextLbl: UILabel!
    @IBOutlet weak var viewForNative: UIView!
    @IBOutlet weak var animationView: UIView!
    private var swipeView: LottieAnimationView?
    
    var nativeRealod:Bool = false
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var index = -1
    
    private var pagerVc: IntroPagerVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeView = LottieAnimationView(name: "Click_2.json")
        swipeView?.loopMode = .loop
        swipeView?.translatesAutoresizingMaskIntoConstraints = false
        if let animationView = swipeView {
            self.animationView.addSubview(animationView)
            NSLayoutConstraint.activate([
                animationView.centerXAnchor.constraint(equalTo: self.animationView.centerXAnchor),
                animationView.centerYAnchor.constraint(equalTo: self.animationView.centerYAnchor),
                animationView.widthAnchor.constraint(equalToConstant: 200),
                animationView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
        
        swipeView?.play()
        self.animationView.isHidden = true
        subscribe()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? IntroPagerVC {
            pagerVc = pageViewController
            pagerVc?.optionDelegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.topLbl.text = "Customize Your App Icons".localized()
//        self.bottomLbl.text = "Style your app your way.".localized()
//        self.doneLbl.text = "Done".localized()
    }
    
    func subscribe() {
        showSkeletonView()
        if Subscribe.get() == false {
            self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                print(" Home...Load Native ....")
                self.viewForNative.isHidden = false
                self.animationView.isHidden = true
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.hideSkeletonView()
                    self.googleNativeAds.showAdsView8(nativeAd: nativeAdsTemp, view: self.viewForNative)
                }
            }
            
            self.googleNativeAds.failAds(self) { fail in
                print(" Home...Native fail....")
                self.viewForNative.isHidden = true
                self.animationView.isHidden = false
            }
            
        } else {
            self.hideSkeletonView()
            viewForNative.isHidden = true
            animationView.isHidden = false
        }
    }
    
    func showSkeletonView() {
        if let adView = Bundle.main.loadNibNamed("SkeletonCustomView4", owner: self, options: nil)?.first as? SkeletonCustomView4 {
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
            adView.view6.showAnimatedGradientSkeleton()
            
        }
    }
    
    func hideSkeletonView() {
        for subview in self.viewForNative.subviews {
            if let adView = subview as? SkeletonCustomView4 {
                adView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        AdsManager.shared.ShowInterstitialAD {}
        setGetStared(status: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeMainVC") as! HomeMainVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
}
extension IntroVC4: OptionControllerDelegate {
    func didUpdateOptionIndex(currentIndex: Int) {
        
        if NativeFaild == false {
            
            if currentIndex == 0 {
                pagerVc?.moveToPage(index: 0, animated: true)
                
            } else if currentIndex == 1 {
                pagerVc?.moveToPage(index: 1, animated: true)
                
            } else if currentIndex == 2 {
                pagerVc?.moveToPage(index: 2, animated: true)
                
            } else if currentIndex == 3 {
                pagerVc?.moveToPage(index: 3, animated: true)
                
            } else if currentIndex == 4 {
                pagerVc?.moveToPage(index: 4, animated: true)
                
            } else if currentIndex == 5 {
                pagerVc?.moveToPage(index: 5, animated: true)
                
            }
            
        } else {
            
            if currentIndex == 0 {
                pagerVc?.moveToPage(index: 0, animated: true)
                
            } else if currentIndex == 1 {
                pagerVc?.moveToPage(index: 1, animated: true)
                
            } else if currentIndex == 2 {
                pagerVc?.moveToPage(index: 2, animated: true)
                
            } else if currentIndex == 3 {
                pagerVc?.moveToPage(index: 3, animated: true)
                
            }
        }
    }
}
