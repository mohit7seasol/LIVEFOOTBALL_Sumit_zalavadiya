//
//  HomePagerVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit

protocol HomePickDelegate {
    func didPickItem(currentItem: Int)
}

class HomePagerVC: UIPageViewController {

    var tabDelegate: HomePickDelegate?
    var arrVc = [UIViewController]()
    var currentPageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.generateArrVc()
        self.setupPager()
    }
    
    private func setupPager() {
        if let startingViewController = contentViewController(at: currentPageIndex) {
            setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)
            tabDelegate?.didPickItem(currentItem: 0)
        }
    }
    
    private func generateArrVc() {
        var index = 0
        let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc1.index = index
        arrVc.append(vc1)
        
        index += 1
        let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "NewsListVC") as! NewsListVC
        vc2.index = index
        arrVc.append(vc2)
        
        index += 1
        let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "FinishedVC") as! FinishedVC
        vc3.index = index
        arrVc.append(vc3)
        
        index += 1
        let vc4 = self.storyboard?.instantiateViewController(withIdentifier: "SeriesVC") as! SeriesVC
        vc4.index = index
        arrVc.append(vc4)
        
        index += 1
        let vc5 = self.storyboard?.instantiateViewController(withIdentifier: "GamesVC") as! GamesVC
        vc5.index = index
        arrVc.append(vc5)
        
    }
    
    private func contentViewController(at index: Int) -> UIViewController? {
        if index < 0 || index >= arrVc.count {
            return nil
        }
        if index < arrVc.count {
            return arrVc[index]
        }
        return nil
    }
    
    func moveToPage(index: Int, animated: Bool) {
        if currentPageIndex != index {
            if index > currentPageIndex {
                if let nextVc = contentViewController(at: index) {
                    setViewControllers([nextVc], direction: .forward, animated: animated, completion: nil)
                }
            } else {
                if let nextVc = contentViewController(at: index) {
                    setViewControllers([nextVc], direction: .reverse, animated: animated, completion: nil)
                }
            }
            currentPageIndex = index
            tabDelegate?.didPickItem(currentItem: currentPageIndex)
        }
    }
    
  

}
