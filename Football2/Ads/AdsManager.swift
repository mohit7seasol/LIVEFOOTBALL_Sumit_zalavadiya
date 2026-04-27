//
//  AdsManager
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.

import Foundation
import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import SystemConfiguration
import UserMessagingPlatform

protocol AdsManagerDelegate {
    func NativeAdLoad()
    func DidDismissFullScreenContent()
    func NativeAdsDidFailedToLoad()
}

var interstitialAd: GADInterstitialAd?
var isNativeLoad : Bool = false

var NATIVE_ADS:GADNativeAd?
var isAdsLoadFailed = Bool()

class AdsManager: NSObject {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    static let shared = AdsManager()
    var delegate: AdsManagerDelegate?
    
    var adLoader: GADAdLoader!
    var arrNativeAds = [GADNativeAd]()
    
    var appOpenAd :GADAppOpenAd?
    var loadTime = Date()
    
    var isMobileAdsStartCalled = Bool()
    
    //MARK:- TOP VIEW CONTROLLER
    
    var topMostViewController: UIViewController? {
        var currentVc = UIApplication.shared.keyWindow?.rootViewController
        while let presentedVc = currentVc?.presentedViewController {
            if let navVc = (presentedVc as? UINavigationController)?.viewControllers.last {
                currentVc = navVc
            } else if let tabVc = (presentedVc as? UITabBarController)?.selectedViewController {
                currentVc = tabVc
            } else {
                currentVc = presentedVc
            }
        }
        return currentVc
    }
    
    //MARK: - App Tracking
    
    func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                
            })
        } else {
        }
    }
    
    
    //MARK: - Request For Content Form
    
    func requestForConsentForms(){
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. false means users are not under age
        // of consent.
        //        parameters.tagForUnderAgeOfConsent = false
        let debugSettings = UMPDebugSettings()
        debugSettings.geography = UMPDebugGeography.EEA
        parameters.debugSettings = debugSettings
        // Request an update for the consent information.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {
            [weak self] requestConsentError in
            guard let self else { return }
            
            if let consentError = requestConsentError {
                // Consent gathering failed.
                return print("Error: \(consentError.localizedDescription)")
            }
            let rootController = UIApplication.shared.keyWindow?.rootViewController //appDelegate.window?.rootViewController
            
            UMPConsentForm.loadAndPresentIfRequired(from: rootController ?? UIViewController()) {
                [weak self] loadAndPresentError in
                guard let self else { return }
                
                if let consentError = loadAndPresentError {
                    // Consent gathering failed.
                    return print("Error: \(consentError.localizedDescription)")
                }
                
                // Consent has been gathered.
                if UMPConsentInformation.sharedInstance.canRequestAds {
                    self.startGoogleMobileAdsSDK()
                }
            }
        }
        
        // Check if you can initialize the Google Mobile Ads SDK in parallel
        // while checking for new consent information. Consent obtained in
        // the previous session can be used to request ads.
        if UMPConsentInformation.sharedInstance.canRequestAds {
            startGoogleMobileAdsSDK()
        }
    }
    
    //    private func startGoogleMobileAdsSDK() {
    //        DispatchQueue.main.async {
    //            guard !self.isMobileAdsStartCalled else { return }
    //
    //            self.isMobileAdsStartCalled = true
    //
    //            // Initialize the Google Mobile Ads SDK.
    //            GADMobileAds.sharedInstance().start()
    //
    //            if Subscribe.get() == false {
    //                AdsManager.shared.loadInterstitialAd()
    //                AdsManager.shared.requestAppOpenAd()
    //                AppOpenAdManager.shared.loadAd()
    //             }
    //        }
    //    }
    
    func requestForConsentForm(completion: @escaping (Bool) -> Void) {
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. false means users are not under age
        // of consent.
        // parameters.tagForUnderAgeOfConsent = false
        let debugSettings = UMPDebugSettings()
        debugSettings.geography = UMPDebugGeography.EEA
        parameters.debugSettings = debugSettings
        // Request an update for the consent information.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { [weak self] requestConsentError in
            guard let self = self else { return }
            
            if let consentError = requestConsentError {
                // Consent gathering failed.
                print("Error: \(consentError.localizedDescription)")
                completion(false) // Consent not granted due to error
                return
            }
            
            let rootController = UIApplication.shared.keyWindow?.rootViewController
            
            UMPConsentForm.loadAndPresentIfRequired(from: rootController ?? UIViewController()) { [weak self] loadAndPresentError in
                guard let self = self else { return }
                
                if let consentError = loadAndPresentError {
                    // Consent gathering failed.
                    print("Error: \(consentError.localizedDescription)")
                    completion(false) // Consent not granted
                    return
                }
                
                // Consent has been gathered.
                if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                    completion(true) // Consent granted
                } else {
                    completion(false) // Consent not granted
                }
            }
        }
        
        // the previous session can be used to request ads.
        if UMPConsentInformation.sharedInstance.canRequestAds {
            startGoogleMobileAdsSDK()
        }
    }
    
    private func startGoogleMobileAdsSDK() {
        DispatchQueue.main.async {
            guard !self.isMobileAdsStartCalled else { return }
            
            self.isMobileAdsStartCalled = true
            
            // Initialize the Google Mobile Ads SDK.
            GADMobileAds.sharedInstance().start()
            
            if Subscribe.get() == false {
                AdsManager.shared.loadInterstitialAd()
                //                Task {
                //                    await AppOpenAdManager.shared.loadAd()
                //                }
            }
        }
    }
    
    
    //MARK: - LOAD INTERSTITIAL ADS
    //    func loadInterstitialAd() {
    //
    //        if !AdsManager.isConnectedToNetwork() && Subscribe.get() {
    //            return
    //        }
    //
    //        let request = GADRequest()
    //        GADInterstitialAd.load(withAdUnitID: !isAdsLoadFailed ?  Application.interstialId : Application.sec_interstialId, request: request) { [self] (ad, error) in
    //            if error != nil {
    //                isAdsLoadFailed = true
    //                loadInterstitialAd()
    //                print("Interstitial load error \(error?.localizedDescription ?? "")")
    ////                Application.interShowFaild = true
    ////                NotificationCenter.default.post(name: .interFail, object: nil)
    //            } else {
    //                print("Interstitial load")
    //                Application.interShowFaild = false
    //                interstitialAd = ad
    //                interstitialAd?.fullScreenContentDelegate = self
    //                isAdsLoadFailed = false
    //            }
    //        }
    //
    //    }
    
    func loadInterstitialAd() {
        
        if !AdsManager.isConnectedToNetwork() && Subscribe.get() {
            return
        }
        
        if interstitialAd == nil {
            
            //  print("inter load nill")
            let request = GADRequest()
            GADInterstitialAd.load(
                withAdUnitID: interstialId, request: request
            ) { (ad, error) in
                if let error = error {
                    interstitialAd = nil
                    //print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    isAdsLoadFailed = true
                    self.loadInterstitialAd()
                    print("Interstitial load error \(error.localizedDescription ?? "")")
                    NotificationCenter.default.post(name: .splashOpenNill, object: nil)
                    NotificationCenter.default.post(name: .getOpenNill, object: nil)
//                    NotificationCenter.default.post(name: .selectMediaTypeNil, object: nil)
                    InterFailed = true
                    //                Application.interShowFaild = true
                    //                NotificationCenter.default.post(name: .interFail, object: nil)
                    
                    return
                }
                print("Interstitial load")
                //  Application.interShowFaild = false
                interstitialAd = ad
                interstitialAd?.fullScreenContentDelegate = self
                isAdsLoadFailed = false
                InterFailed = false
                //  interstitialAd = ad
                //  interstitialAd?.fullScreenContentDelegate = self
                
            }
        } else {
            // print("inter load not nill")
        }
        
    }
    
    
    //MARK: - LOAD NATIVE ADS
    
    func createAndLoadNativeAds(numberOfAds: Int) {
        
        if !AdsManager.isConnectedToNetwork() && Subscribe.get(){
            return
        }
        arrNativeAds.removeAll()
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = numberOfAds
        
        adLoader = GADAdLoader(adUnitID: nativeId, rootViewController: topMostViewController,
                               adTypes: [GADAdLoaderAdType.native],
                               options: [multipleAdsOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    
    
    //MARK: - LOAD APP OPEN ADS
    
    func tryToPresentAppOpenAd() {
        if Subscribe.get(){
            return
        }
        let ad = appOpenAd
        appOpenAd = nil
        
        if let ad = ad {
            if let rootController = getTopViewController(){
                ad.present(fromRootViewController: rootController)
            }
            
            requestAppOpenAd()
        } else {
            requestAppOpenAd()
        }
    }
    
    func requestAppOpenAd() {
        if Subscribe.get(){
            return
        }
        appOpenAd = nil
        GADAppOpenAd.load(
            withAdUnitID: appopenId,
            request: GADRequest(),
            completionHandler: { [self] appOpenAd, error in
                if let error = error {
                    isAdsLoadFailed = true
                    requestAppOpenAd()
                    //  print("Failed to load app open ad: \(error)")
                    return
                }
                isAdsLoadFailed = false
                self.appOpenAd = appOpenAd
                self.appOpenAd?.fullScreenContentDelegate = self
                self.loadTime = Date()
            })
    }
    
    //MARK: - PRESENT (INTERSITITAL, NATIVE) ADS
    func showInterstitialAd (_ isLoader:Bool = false, isRandom:Bool = false, ratio:Int = 3,shouldMatchRandom : Int = 2){
        
        
        if interstitialAd != nil {
            //            if isLoader {
            //                SVProgressHUD.show(withStatus: "Loading Ads...")
            //
            //                SVProgressHUD.dismiss(withDelay: 0.5) {
            //                    self.checkRandomAndPresentInterstitial(isRandom: isRandom, ratio: ratio, shouldMatchRandom: shouldMatchRandom)
            //                }
            //            }
            //            else{
            //                self.checkRandomAndPresentInterstitial(isRandom: isRandom, ratio: ratio, shouldMatchRandom: shouldMatchRandom)
            //            }
            
            self.checkRandomAndPresentInterstitial(isRandom: isRandom, ratio: ratio, shouldMatchRandom: shouldMatchRandom)
            
        } else {
            //print("intersisital Ad wasn't ready")
        }
        
        
    }
    
    func checkRandomAndPresentInterstitial( isRandom:Bool, ratio:Int,shouldMatchRandom :Int){
        if isRandom{
            let isRandomMatch = Int.random(in: 1 ... ratio) == shouldMatchRandom
            if isRandomMatch {
                self.presentInterstitialAd()
            }
        }
        else {
            self.presentInterstitialAd()
        }
    }
    
    func presentInterstitialAd() {
        if Subscribe.get(){
            return
        }
        DispatchQueue.main.async {
            if let rootController = getTopViewController(){
                interstitialAd?.present(fromRootViewController: rootController)
            }
        }
    }
    
    //    func presentInterstitialAd1(vc:UIViewController) {
    //        if Subscribe.get(){
    //            return
    //        }
    //        DispatchQueue.main.async {
    //            if interstitialAd != nil {
    //                isInterShow = true
    //                interstitialAd!.present(fromRootViewController: vc)
    //
    //            } else{
    //               // print("intersitial not load")
    //            }
    //        }
    //    }
    private var interstitialCompletion: (() -> Void)?
    
    func presentInterstitialAd1(vc: UIViewController, completion: @escaping () -> Void) {
        if Subscribe.get() {
            completion()
            return
        }
        
        interstitialCompletion = completion
        
        DispatchQueue.main.async {
            if let interstitialAd = interstitialAd {
                interstitialAd.fullScreenContentDelegate = self
                interstitialAd.present(fromRootViewController: vc)
            } else {
                self.loadInterstitialAd()
                completion()
            }
        }
    }
    
    func ShowInterstitialAD(completion: @escaping () -> Void) {
        if Subscribe.get() == false {
            adsPlus =  adsPlus+1
            if  adsPlus % adsCount == 0
            {
                isInterShown = true
                AdsManager.shared.presentInterstitialAd1(vc: getTopViewController() ?? UIViewController(), completion: completion)
            } else {
                isInterShown = false
                completion()
            }
        }
    }
    
    func ShowFixInterstitialAD(completion: @escaping () -> Void) {
        if Subscribe.get() == false {
              
                AdsManager.shared.presentInterstitialAd()
            
        }
    }
    /*
     func PresentPremiumVC(completion: @escaping () -> Void) {
     
     let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
     if let premiumVC = storyboard.instantiateViewController(withIdentifier: "PremiumVC") as? PremiumVC {
     premiumVC.dismissCompletion = {
     completion()
     }
     if let topViewController = getTopViewController() {
     topViewController.present(premiumVC, animated: true, completion: nil)
     }
     }
     }
     */
}


// MARK: - Interstitial Delegate
extension AdsManager: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        //  print("Ad did fail to present full screen content.", error.localizedDescription)
        adsPlus = 0
        isAdsLoadFailed = true
        loadInterstitialAd()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
        self.delegate?.DidDismissFullScreenContent()
    }
    
    //    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    //      //  print("Ad did dismiss full screen content.")
    //        isInterShow = false
    //        interstitialAd = nil
    //        loadInterstitialAd()
    //        NotificationCenter.default.post(name: .splashOpenClose, object: nil)
    //        NotificationCenter.default.post(name: .getOpenClose, object: nil)
    //       // NotificationCenter.default.post(name: .closeHomeInter, object: nil)
    //    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Present PremiumVC on dismiss of interstitialAd
        
        
        // Reset interstitialAd after dismissal
        interstitialAd = nil
        loadInterstitialAd()
        
        // Post notifications or handle other actions as needed
        NotificationCenter.default.post(name: .splashOpenClose, object: nil)
        NotificationCenter.default.post(name: .selectMediaType, object: nil)
        NotificationCenter.default.post(name: .getOpenClose, object: nil)
        self.interstitialCompletion?()
    }
}




// MARK: - NativeAd Loader Delegate
extension AdsManager: GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        //        print("did Receive Native Ad \(nativeAd)")
        isNativeLoad = true
        arrNativeAds.append(nativeAd)
        self.delegate?.NativeAdLoad()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        //  print("\(adLoader) failed with error: \(error.localizedDescription)")
        isNativeLoad = false
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        
    }
    
}



// MARK: - Google Banner Ads -

class GoogleBannerAds: NSObject, GADBannerViewDelegate {
    
    var view: GADBannerView!
    
    func loadAds(vc: UIViewController, view : GADBannerView) {
        if Subscribe.get(){
            return
        }
        view.isHidden = true
        let viewWidth = view.frame.size.width
        
        self.view = view
        self.view.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        self.view.adUnitID = bannerId
        self.view.rootViewController = vc
        self.view.delegate = self
        self.view.load(GADRequest())
    }
    
    // MARK: GADBannerViewDelegate Methods
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        view.isHidden = false
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        view.isHidden = true
    }
    
}


// MARK: - Google Native Ads -
class GoogleNativeAds: NSObject, GADNativeAdLoaderDelegate {
    
    var completion: ((GADNativeAd) -> Void)?
    var fail: ((Error) -> Void)?
    var adLoader: GADAdLoader!
    
    func loadAds(_ vc: UIViewController, _ completion: @escaping (GADNativeAd) -> Void) {
        if Subscribe.get(){
            return
        }
        print("Native Comple..")
        self.completion = completion
        
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        self.adLoader = GADAdLoader(adUnitID: nativeId, rootViewController: vc, adTypes: [GADAdLoaderAdType.native], options: [multipleAdsOptions])
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
        
    }
    
    func loadFullNativeAds(_ vc: UIViewController, _ completion: @escaping (GADNativeAd) -> Void) {
        if Subscribe.get(){
            return
        }
        print("Native Comple..")
        self.completion = completion
        
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        self.adLoader = GADAdLoader(adUnitID: fullScreenNativeId, rootViewController: vc, adTypes: [GADAdLoaderAdType.native], options: [multipleAdsOptions])
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
        
    }
    
    func loadInlineNativeAds(_ vc: UIViewController, _ completion: @escaping (GADNativeAd) -> Void) {
        if Subscribe.get(){
            return
        }
        print("Native Comple..")
        self.completion = completion
        
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        self.adLoader = GADAdLoader(adUnitID: inlineNativeBannerId, rootViewController: vc, adTypes: [GADAdLoaderAdType.native], options: [multipleAdsOptions])
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
        
    }
    
    func failAds(_ vc: UIViewController, _ fail: @escaping (Error) -> Void ) {
        if Subscribe.get(){
            return
        }
        print("Native Fail..")
        self.fail = fail
    }
    
    func failFullNativeAds(_ vc: UIViewController, _ fail: @escaping (Error) -> Void ) {
        if Subscribe.get(){
            return
        }
        print("Native Fail..")
        self.fail = fail
    }
    
    func failInlineNativeAds(_ vc: UIViewController, _ fail: @escaping (Error) -> Void ) {
        if Subscribe.get(){
            return
        }
        print("Native Fail..")
        self.fail = fail
    }
    
    
    // MARK: - GADNativeAdLoaderDelegate Methods
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        //  print("Native completion..")
        completion!(nativeAd)
        print("Native completion..")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        
        fail?(error)
        print("Native error")
        debugPrint("Error: \(error.localizedDescription)")
    }
    
    //MARK: - Load View Methods
    
    let googleNativeAdsCustomeView1: GoogleNativeAdsCustomeView1 = GoogleNativeAdsCustomeView1.instanceFromNib() as! GoogleNativeAdsCustomeView1
    /// Load big native ads
    func showAdsView1(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView1)
        googleNativeAdsCustomeView1.nativeAd = nativeAd
        googleNativeAdsCustomeView1.setup()
    }
    
    let googleNativeAdsCustomeView2: GoogleNativeAdsCustomeView2 = GoogleNativeAdsCustomeView2.instanceFromNib() as! GoogleNativeAdsCustomeView2
    /// Load Ads like table view cell (Like Banner Ads)
    func showAdsView2(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView2)
        googleNativeAdsCustomeView2.nativeAd = nativeAd
        googleNativeAdsCustomeView2.setup()
    }
    
    let googleNativeAdsCustomeView4: GoogleNativeAdsCustomeView4 = GoogleNativeAdsCustomeView4.instanceFromNib() as! GoogleNativeAdsCustomeView4
    /// Load Ads like table view cell (Like Banner Ads)
    func showAdsView4(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView4)
        googleNativeAdsCustomeView4.nativeAd = nativeAd
        googleNativeAdsCustomeView4.setup()
    }
    
    let googleNativeAdsCustomeView3: GoogleNativeAdsCustomeView3 = GoogleNativeAdsCustomeView3.instanceFromNib() as! GoogleNativeAdsCustomeView3
    /// Load Ads like table view cell (Like Banner Ads)
    func showAdsView3(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView3)
        googleNativeAdsCustomeView3.nativeAd = nativeAd
        googleNativeAdsCustomeView3.setup()
    }
    
    let googleNativeAdsCustomeView5: GoogleNativeAdsCustomeView5 = GoogleNativeAdsCustomeView5.instanceFromNib() as! GoogleNativeAdsCustomeView5
    /// Load big native ads
    func showAdsView5(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView5)
        googleNativeAdsCustomeView5.nativeAd = nativeAd
        googleNativeAdsCustomeView5.setup()
    }
    
    let googleNativeAdsCustomeView6: GoogleNativeAdsCustomeView6 = GoogleNativeAdsCustomeView6.instanceFromNib() as! GoogleNativeAdsCustomeView6
    /// Load big native ads
    func showAdsView6(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView6)
        googleNativeAdsCustomeView6.nativeAd = nativeAd
        googleNativeAdsCustomeView6.setup()
    }
    
        let googleNativeAdsCustomeView7: GoogleNativeAdsCustomeView7 = GoogleNativeAdsCustomeView7.instanceFromNib() as! GoogleNativeAdsCustomeView7
        /// Load Full native ads
        func showAdsView7(nativeAd: GADNativeAd, view: UIView) {
            view.isHidden = false
            displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView7)
            googleNativeAdsCustomeView7.nativeAd = nativeAd
            googleNativeAdsCustomeView7.setup()
        }
    
    let googleNativeAdsCustomeView8: GoogleNativeAdsCustomeView8 = GoogleNativeAdsCustomeView8.instanceFromNib() as! GoogleNativeAdsCustomeView8
        /// Load Media native ads
        func showAdsView8(nativeAd: GADNativeAd, view: UIView) {
            view.isHidden = false
            displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView8)
            googleNativeAdsCustomeView8.nativeAd = nativeAd
            googleNativeAdsCustomeView8.setup()
        }
    
    //    func changecolor() {
    //        googleNativeAdsCustomeView6.blackColor = true
    //    }
    //
    //    func notChangecolor() {
    //        googleNativeAdsCustomeView6.blackColor = false
    //    }
    
}

// MARK: - Display view into subview
func displaySubViewtoParentView(_ parentview: UIView! , subview: UIView!) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    parentview.addSubview(subview);
    parentview.addConstraint(NSLayoutConstraint(item: subview!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
    parentview.layoutIfNeeded()
}

func getTopViewController() -> UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    return nil
}
