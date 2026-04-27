//
//  IntroVC2.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import Lottie

class IntroVC2: UIViewController {

    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var bottomLbl: UILabel!
    @IBOutlet weak var nextLbl: UILabel!
    @IBOutlet weak var swipeAnimationView: UIView!
    private var swipeView: LottieAnimationView?
    var index = -1
    
    private var pagerVc: IntroPagerVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeView = LottieAnimationView(name: "Swipe.json")
        swipeView?.loopMode = .loop
        swipeView?.translatesAutoresizingMaskIntoConstraints = false
        if let animationView = swipeView {
            self.swipeAnimationView.addSubview(animationView)
            NSLayoutConstraint.activate([
                animationView.centerXAnchor.constraint(equalTo: self.swipeAnimationView.centerXAnchor),
                animationView.centerYAnchor.constraint(equalTo: self.swipeAnimationView.centerYAnchor),
                animationView.widthAnchor.constraint(equalToConstant: 200),
                animationView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
        
        swipeView?.play()
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
        self.topLbl.text = "Live Football Scores, Updates, & Match Streams".localized()
        self.bottomLbl.text = "Real-time scores, instant updates, and HD streams.".localized()
        self.nextLbl.text = "Next".localized()
    }
    @IBAction func nextTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: .step3Next, object: nil)
    }
    
}
extension IntroVC2: OptionControllerDelegate {
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
