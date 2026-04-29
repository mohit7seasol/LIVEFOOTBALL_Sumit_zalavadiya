//
//  BigNativeVC1.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import SkeletonView

class BigNativeVC1: UIViewController {

    @IBOutlet weak var viewForNative: UIView!
    
    var index = -1
    
    private var pagerVc: IntroPagerVC?
    var timer: Timer?
    var counter = 0
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if fullNativeAdsTemp == nil {
            subscribe()
        } else {
            self.viewForNative.isHidden = false
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.hideSkeletonView()
                self.googleNativeAds.showAdsView7(nativeAd: fullNativeAdsTemp!, view: self.viewForNative)
            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if fromScreen1 == true {
//            fromScreen1 = false
            startTimer()
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    func startTimer() {
        self.counter = 0
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        self.counter += 1
        if self.counter == 6 {
            self.timer?.invalidate()
            self.timer = nil
            NotificationCenter.default.post(name: .step4Next, object: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? IntroPagerVC {
            pagerVc = pageViewController
            pagerVc?.optionDelegate = self
        }
    }
    
    @objc func navigate() {
        NotificationCenter.default.post(name: .step4Next, object: nil)
    }
    
    func subscribe() {
        showSkeletonView()
        if Subscribe.get() == false {
            self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                print(" Home...Load Native ....")
                self.viewForNative.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.hideSkeletonView()
                    self.googleNativeAds.showAdsView7(nativeAd: nativeAdsTemp, view: self.viewForNative)
                }
            }
            
            self.googleNativeAds.loadAds(self) { fail in
                print(" Home...Native fail....")
                self.viewForNative.isHidden = true
            }
            
        } else {
            self.hideSkeletonView()
            viewForNative.isHidden = true
        }
    }
    
    func showSkeletonView() {
        if let adView = Bundle.main.loadNibNamed("SkeletonCustomView8", owner: self, options: nil)?.first as? SkeletonCustomView8 {
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
            if let adView = subview as? SkeletonCustomView8 {
                adView.removeFromSuperview()
            }
        }
    }
    
    
}

extension BigNativeVC1: OptionControllerDelegate {
    func didUpdateOptionIndex(currentIndex: Int) {
        
        if NativeFaild == false {
            
            if currentIndex == 0 {
                fromScreen1 = true
                pagerVc?.moveToPage(index: 0, animated: true)
                
            } else if currentIndex == 1 {
                fromScreen1 = false
                pagerVc?.moveToPage(index: 1, animated: true)
                
            } else if currentIndex == 2 {
                fromScreen1 = false
                pagerVc?.moveToPage(index: 2, animated: true)
                
            } else if currentIndex == 3 {
                fromScreen1 = false
                pagerVc?.moveToPage(index: 3, animated: true)
                
            }
            
        } else {
            
            if currentIndex == 0 {
                pagerVc?.moveToPage(index: 0, animated: true)
                
            } else if currentIndex == 1 {
                pagerVc?.moveToPage(index: 1, animated: true)
                
            } else if currentIndex == 2 {
                pagerVc?.moveToPage(index: 2, animated: true)
                
            }
        }
    }
}
