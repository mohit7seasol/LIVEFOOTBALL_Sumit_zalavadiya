//
//  SplashVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import Lottie
import GoogleMobileAds
import SwiftyJSON
import AWSCore
import SwiftyJSON
import Alamofire
import AppTrackingTransparency
import AdSupport

class SplashVC: UIViewController {

    @IBOutlet weak var appNameLbl: UILabel!
    private var loaderView: LottieAnimationView?
    
    var appOpenAd: GADAppOpenAd?
    var googleNativeAds = GoogleNativeAds()
    var oneTime:Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.appNameLbl.text = APPNAME
        
        loaderView = LottieAnimationView(name: "LoadingAnimation.json")
        loaderView?.loopMode = .loop
        loaderView?.translatesAutoresizingMaskIntoConstraints = false
        if let animationView = loaderView {
            self.view.addSubview(animationView)
            NSLayoutConstraint.activate([
                animationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                animationView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
                animationView.widthAnchor.constraint(equalToConstant: 300),
                animationView.heightAnchor.constraint(equalToConstant: 80)
            ])
        }
        
        loaderView?.play()
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        //            self.navigate()
        //        }
        
        self.webservice_getJSON_apiAds(url: getJSON, params: [:], header: [:])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onNavigate),name: .splashOpenClose,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNavigateNill),name: .splashOpenNill,object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    
    
    @objc func onNavigate() {
        if isfromeAppStart == true {
            isfromeAppStart = false
            if oneTime == true {
                
            } else {
                oneTime = true
                DispatchQueue.main.async {
                    self.navigate()
                }
            }
        }
    }
    
    @objc func onNavigateNill() {
        if isfromeAppStart == true {
            isfromeAppStart = false
            if oneTime == true {
                
            } else {
                oneTime = true
                DispatchQueue.main.async {
                    self.navigate()
                }
            }
        }
    }
    
    func navigate() {
        if isShowLanguage() == true && isGetStared() == false {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "IntroMainVC") as! IntroMainVC
            self.navigationController?.pushViewController(vc, animated: false)
        }else if isGetStared() == true {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeMainVC") as! HomeMainVC
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            isFromSplash = true
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    
    
    func navigateToVc() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2.5) {
            let credentials = AWSStaticCredentialsProvider(accessKey: ACCESS, secretKey: SECRET)
            let configuration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credentials)
            
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            AdsManager.shared.requestForConsentForm { (isConsentGranted) in
                
                if Subscribe.get() == false {
                    if isConsentGranted {
                        isfromeAppStart = true
                        print("Granted")
                        
                        AppOpenAdManager.shared.showAdIfAvailable(viewController: self)
                        
                    } else {
                        isfromeAppStart = true
                        if isShowParmission() == true {
                            if Subscribe.get() == false {
                                Task {
                                    await AppOpenAdManager.shared.loadAd()
                                    
                                }
                                AppOpenAdManager.shared.showAdIfAvailable(viewController: self)
                                
                            } else {
                                DispatchQueue.main.async {
                                    self.navigate()
                                }
                            }
                            
                        } else {
                            
                            AppOpenAdManager.shared.showAdIfAvailable(viewController: self)
                        }
                        print("DEnied")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigate()
                    }
                }
                
            }
            
        }
        
    }
    
    
}
extension SplashVC {
    
    func webservice_getJSON_apiAds(url : String,params : NSDictionary,header:[String:String]) {
        WebServices().CallGlobalAPI(url: url, headers: header, parameters: params, httpMethod: "GET", progressView: false, uiView : self.view, networkAlert: true) {( _ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0
            {
                showAlertMsg(Message:  SERVER_ERROR, AutoHide: false)
            } else {
                let jsonDict = jsonResponse!.dictionaryValue
                print("....\(jsonDict)")
                if jsonDict.isEmpty {
                    showAlertMsg(Message:  SERVER_ERROR, AutoHide: false)
                } else {
                    
                    bannerId = jsonDict["bannerId"]?.stringValue ?? ""
                    nativeId = jsonDict["nativeId"]?.stringValue ?? ""
                    interstialId = jsonDict["interstialId"]?.stringValue ?? ""
                    appopenId = jsonDict["appopenId"]?.stringValue ?? ""
                    rewardId = jsonDict["rewardId"]?.stringValue ?? ""
//                    MARK: - Live IDs
//                    fullScreenNativeId = jsonDict["extraFields"]?["full_native_adaptive"].stringValue ?? ""
//                    inlineNativeBannerId = jsonDict["extraFields"]?["inline_native_banner"].stringValue ?? ""
//                    MARK: - Testing IDs
                    fullScreenNativeId = jsonDict["extraFields"]?["secNativeId"].stringValue ?? ""
                    inlineNativeBannerId = jsonDict["extraFields"]?["secNativeId"].stringValue ?? ""
                    
                    addButtonColor = jsonDict["addButtonColor"]?.stringValue ?? "#7462FF"
                    var customInterstial = jsonDict["customInterstial"]?.intValue ?? 0
                    
                    gamesURL = jsonDict["extraFields"]?["web_url"].stringValue ?? ""
                    
                    adsCount = jsonDict["afterClick"]?.intValue ?? 4
                    adsPlus = customInterstial == 0  ?  adsCount - 1 : adsCount
                    
#if DEBUG
                    APITOKEN = "4c8a6959d4mshdda890c244de333p1a9559jsnfa944e297289"
#else
                    APITOKEN = jsonDict["extraFields"]?["tokenId"].stringValue ?? ""
#endif
                    
                    if Subscribe.get() == false {
                        
                        self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                            print(" Home...Load Native ....")
                            NativeFailedToLoad = false
                        }
                        
                        self.googleNativeAds.failAds(self) { fail in
                            print(" Home...Native fail....")
                            NativeFailedToLoad = true
                        }
                        
                        self.googleNativeAds.loadFullNativeAds(self) { nativeAdsTemp in
                            print(" Home...Load Full Native ....")
                            NativeFaild = false
                            fullNativeAdsTemp = nativeAdsTemp
                        }
                        
                        self.googleNativeAds.failFullNativeAds(self) { fail in
                            print(" Home...Full Native fail....")
                            NativeFaild = true
                            fullNativeAdsTemp = nil
                        }
                        
                        Task {
                            await AppOpenAdManager.shared.loadAd()
                        }
                        AdsManager.shared.loadInterstitialAd()
                        
                    }
                    self.navigateToVc()
                }
                
            }
        }
        
    }
}
