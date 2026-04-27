//
//  IntroMainVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit

class IntroMainVC: UIViewController {

    private var pagerVc: IntroPagerVC?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? IntroPagerVC {
            pagerVc = pageViewController
            pagerVc?.optionDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logAnalyticAction(title: "", status: .Intro)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Next2(noti:)), name: .step2Next, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Next3(noti:)), name: .step3Next, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Next4(noti:)), name: .step4Next, object: nil)
    }
    
    @objc func Next2(noti: Notification) {
//        fromScreen1 = true
        if NativeFaild == false {
            pagerVc?.moveToPage(index: 1, animated: true)
        } else {
            pagerVc?.moveToPage(index: 1, animated: true)
        }
    }
    
    @objc func Next3(noti: Notification) {
        if NativeFaild == false {
            pagerVc?.moveToPage(index: 2, animated: true)
        } else {
            pagerVc?.moveToPage(index: 2, animated: true)
        }
        
    }
    
    @objc func Next4(noti: Notification) {
        if NativeFaild == false {
            pagerVc?.moveToPage(index: 3, animated: true)
        } else {
            pagerVc?.moveToPage(index: 2, animated: true)
        }
        
    }
    
}


extension IntroMainVC: OptionControllerDelegate {
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
