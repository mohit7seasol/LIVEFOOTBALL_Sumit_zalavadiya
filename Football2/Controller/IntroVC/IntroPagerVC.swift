//
//  IntroPagerVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit

//MARK: -------------------- Protocol Methods --------------------
protocol OptionControllerDelegate {
    func didUpdateOptionIndex(currentIndex: Int)
}

class IntroPagerVC: UIPageViewController {

    //MARK: -------------------- Variables --------------------
    var optionDelegate: OptionControllerDelegate?
    var arrVc = [UIViewController]()
    var currentPageIndex = 0
    
    //MARK: -------------------- View Delegate Method --------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.generateArrVc()
        self.setupPager()
        
    }
    
    //MARK: -------------------- Functions --------------------
    private func setupPager() {
        dataSource = self
        delegate = self
        
        if let startingViewController = contentViewController(at: currentPageIndex) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
            optionDelegate?.didUpdateOptionIndex(currentIndex: 0)
        }
    }
    
    private func generateArrVc() {
        var index = 0
        if NativeFaild == false {
          
            let vc1 = IntroVC1.instantiate(fromAppStoryboard: .Main)
            vc1.index = index
            arrVc.append(vc1)
            
            index += 1
            let vc2 = IntroVC2.instantiate(fromAppStoryboard: .Main)
            vc2.index = index
            arrVc.append(vc2)
            
            index += 1
            let vc3 = BigNativeVC1.instantiate(fromAppStoryboard: .Main)
            vc3.index = index
            arrVc.append(vc3)
            
            index += 1
            let vc4 = IntroVC3.instantiate(fromAppStoryboard: .Main)
            vc4.index = index
            arrVc.append(vc4)
            
            
        } else {
           
            let vc1 = IntroVC1.instantiate(fromAppStoryboard: .Main)
            vc1.index = index
            arrVc.append(vc1)
            
            index += 1
            let vc2 = IntroVC2.instantiate(fromAppStoryboard: .Main)
            vc2.index = index
            arrVc.append(vc2)
            
            index += 1
            let vc3 = IntroVC3.instantiate(fromAppStoryboard: .Main)
            vc3.index = index
            arrVc.append(vc3)
            
        }
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
            optionDelegate?.didUpdateOptionIndex(currentIndex: currentPageIndex)
        }
    }
}

//MARK: -------------------- UIPageViewControllerDataSource, UIPageViewControllerDelegate --------------------
extension IntroPagerVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if NativeFaild == false {
            if let vc = viewController as? IntroVC1 {
                var index = vc.index
                index -= 1
                return contentViewController(at: index)
            } else if let vc = viewController as? IntroVC2 {
                var index = vc.index
                index -= 1
                return contentViewController(at: index)
            } else if let vc = viewController as? BigNativeVC1 {
                var index = vc.index
                index -= 1
                return contentViewController(at: index)
            } else if let vc = viewController as? IntroVC3 {
                var index = vc.index
                index -= 1
                return contentViewController(at: index)
            }
        } else {
            if let vc = viewController as? IntroVC1 {
                var index = vc.index
                index -= 1
                return contentViewController(at: index)
            } else if let vc = viewController as? IntroVC2 {
                var index = vc.index
                index -= 1
                return contentViewController(at: index)
            } else if let vc = viewController as? IntroVC3 {
                var index = vc.index
                index -= 1
                return contentViewController(at: index)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if NativeFaild == false {
            if let vc = viewController as? IntroVC1 {
                var index = vc.index
                index += 1
                return contentViewController(at: index)
            } else if let vc = viewController as? IntroVC2 {
                var index = vc.index
                index += 1
                return contentViewController(at: index)
            } else if let vc = viewController as? BigNativeVC1 {
                var index = vc.index
                index += 1
                return contentViewController(at: index)
            } else if let vc = viewController as? IntroVC3 {
                var index = vc.index
                index += 1
                return contentViewController(at: index)
            }
            
        } else {
            if let vc = viewController as? IntroVC1 {
                var index = (vc.index)
                index += 1
                return contentViewController(at: index)
            } else if let vc = viewController as? IntroVC2 {
                var index = vc.index
                index += 1
                return contentViewController(at: index)
            } else if let vc = viewController as? IntroVC3 {
                var index = vc.index
                index += 1
                return contentViewController(at: index)
            }
        }
        return nil
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if NativeFaild == false {
                 if let contentViewController = pageViewController.viewControllers?.first as? IntroVC1 {
                    currentPageIndex = contentViewController.index
                    optionDelegate?.didUpdateOptionIndex(currentIndex: contentViewController.index)
                } else if let contentViewController = pageViewController.viewControllers?.first as? IntroVC2 {
                    currentPageIndex = contentViewController.index
                    optionDelegate?.didUpdateOptionIndex(currentIndex: contentViewController.index)
                } else if let contentViewController = pageViewController.viewControllers?.first as? BigNativeVC1 {
                    currentPageIndex = contentViewController.index
                    optionDelegate?.didUpdateOptionIndex(currentIndex: contentViewController.index)
                } else if let contentViewController = pageViewController.viewControllers?.first as? IntroVC3 {
                    currentPageIndex = contentViewController.index
                    optionDelegate?.didUpdateOptionIndex(currentIndex: contentViewController.index)
                }
                
            } else {
                if let contentViewController = pageViewController.viewControllers?.first as? IntroVC1 {
                    currentPageIndex = contentViewController.index
                    optionDelegate?.didUpdateOptionIndex(currentIndex: contentViewController.index)
                } else if let contentViewController = pageViewController.viewControllers?.first as? IntroVC2 {
                    currentPageIndex = contentViewController.index
                    optionDelegate?.didUpdateOptionIndex(currentIndex: contentViewController.index)
                } else if let contentViewController = pageViewController.viewControllers?.first as? IntroVC3 {
                    currentPageIndex = contentViewController.index
                    optionDelegate?.didUpdateOptionIndex(currentIndex: contentViewController.index)
                } 
            }
        }
    }
}
