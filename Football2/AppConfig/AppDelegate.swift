//
//  AppDelegate.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import AWSCore
import AWSS3
import GoogleMobileAds
import IQKeyboardManagerSwift
import SVProgressHUD
import AppTrackingTransparency
import FirebaseCore
import FirebaseMessaging
import FirebasePerformance

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var appOpenAd: AppOpenAd?
    private var isShowingAppOpenAd = false
    var myOrientation: UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initView()
        FirebaseApp.configure()
        FirebaseApp.debugDescription()
        // Enable performance monitoring
        Performance.sharedInstance().isInstrumentationEnabled = true
        Performance.sharedInstance().isDataCollectionEnabled = true
        FirebaseConfiguration.shared.setLoggerLevel(FirebaseLoggerLevel.min)
        setTimeZone()
        Preference.sharedInstance.setupDefaults()
        return true
    }
    
    func initView() {
        let adsModal = getAdsModal()
        
        appopenId = appopenId ?? ""
        nativeId = nativeId ?? ""
        
        AdsManager.shared.requestAppOpenAd()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            Task {
                await AppOpenAdManager.shared.loadAd()
            }
        })
        
        APIManager().GET_API(api: getJSON, isShowLoader: true) { data in
            do {
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    let adsModal = try jsonDecoder.decode(AdsModal.self, from: data)
                    appopenId = appopenId ?? ""
                    nativeId = nativeId ?? ""
                    setAdsModal(modal: adsModal)
                }
            } catch {
                //print("Error decoding JSON: \(error)")
            }
        }
        
    }
    
    func getDeviceLocalTimeZone() -> TimeZone {
        return TimeZone.current
    }
    
    func setTimeZone() {
        let deviceTimeOffset =  -330 + getDeviceLocalTimeZone().secondsFromGMT() / 60
        
        print(deviceTimeOffset)
        
        let hours = deviceTimeOffset / 60
        let remainingMinutes = deviceTimeOffset % 60
        
        let formattedTime = String(format: "%02d:%02d", hours, remainingMinutes)
        timeOffSet = formattedTime
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

