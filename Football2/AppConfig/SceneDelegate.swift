//
//  SceneDelegate.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import AVFoundation
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds
import StoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate , FullScreenContentDelegate {
    
    var window: UIWindow?
    private(set) static var shared: SceneDelegate?
    
    var appOpenAd: AppOpenAd?
    var loadTime = Date()
    var bgApp:Bool = false
    var appStarts:Bool = false
    
    var idfa: UUID {
        return ASIdentifierManager.shared().advertisingIdentifier
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            
            if Subscribe.get() == false {
                
                if appStart == true {
                    appStart = false
                    if Subscribe.get() == false {
                        if isInterShown == false {
                            self.tryToPresentAd()
                        }
                    }
                }
                if self.bgApp == true {
                    self.bgApp = false
                    if Subscribe.get() == false {
                        
                        if isInterShown == false {
                            self.tryToPresentAd()
                        }
                    }
                }
                
            } else {
                
            }
            
        })
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        self.bgApp = true
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func requestAppOpenAd() {
        
        if Subscribe.get() == false {
            // if UIApplication.isFirstLaunch() {
            let request = Request()
            AppOpenAd.load(with: appopenId,
                              request: request,
                              completionHandler: { (appOpenAdIn, _) in
                self.appOpenAd = appOpenAdIn
                self.appOpenAd?.fullScreenContentDelegate = self
                print("Ad is ready")
            })
        } else {
            //Purchase
        }
        
    }
    
    
    func tryToPresentAd() {
        if let gOpenAd = self.appOpenAd, let rwc = UIApplication.shared.windows.last?.rootViewController {
            gOpenAd.present(from: rwc)
        } else {
            self.requestAppOpenAd()
        }
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if Subscribe.get() == false {
            self.requestAppOpenAd()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        if Subscribe.get() == false {
            self.requestAppOpenAd()
            NotificationCenter.default.post(name: .splashOpenClose, object: nil)
        }
        
    }
    
    
}
