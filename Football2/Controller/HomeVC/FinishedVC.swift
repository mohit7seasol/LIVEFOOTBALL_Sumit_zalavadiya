//
//  FinishedVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit

struct MatchFinished {
    let m_name: String
    let result_str: String
    let t1_sname: String
    let t2_sname: String
    let t1_flag: String
    let t2_flag: String
    let t1_goal: Int
    let t2_goal: Int
    let strt_time_ts: Int
    let gameState: String
    let time: String
    let m_id: String
    let l_id: String
}

extension MatchFinished: Comparable {
    
    static func < (lhs: MatchFinished, rhs: MatchFinished) -> Bool {
        return lhs.strt_time_ts < rhs.strt_time_ts
    }
}

class FinishedVC: UIViewController {

    @IBOutlet weak var domesticView: CustomView!
    @IBOutlet weak var internationView: CustomView!
    @IBOutlet weak var matchCollectionView: UICollectionView! {
        didSet {
            matchCollectionView.register(UINib(nibName: "FinishedCell", bundle: nil), forCellWithReuseIdentifier: "FinishedCell")
            matchCollectionView.register(UINib(nibName: "ShowNativeHome", bundle: nil), forCellWithReuseIdentifier: "ShowNativeHome")
            matchCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    
    var viewForNative = UIView()
    var nativeRealod:Bool = false
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var matchesFinished: [MatchFinished] = []
    var isAscending: Bool = true
    var currentCategory = ""
    
    var index = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .FinishedMatches)
        
        viewForNative = UIView()
        viewForNative.backgroundColor = .clear
        
        self.domesticView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
        self.domesticView.applyBorder(0, borderColor: .clear)
        
        self.internationView.backgroundColor = .clear
        self.internationView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.currentCategory = "Domestic"
        self.ProgressViewShow(uiView: self.view)
        fetchFinishedMatches()
        subscribe()
    }
    
    func subscribe() {
        showSkeletonView()
        if Subscribe.get() == false {
            self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                print(" Home...Load Native ....")
                self.viewForNative.isHidden = false

                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.hideSkeletonView()
                    self.googleNativeAds.showAdsView8(nativeAd: nativeAdsTemp, view: self.viewForNative)
                }
            }

            self.googleNativeAds.failAds(self) { fail in
                print(" Home...Native fail....")
                self.viewForNative.isHidden = true
            }

        } else {
            self.hideSkeletonView()
            viewForNative.isHidden = true
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
        
    @IBAction func domesticTapped(_ sender: UIButton) {
        self.domesticView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
        self.domesticView.applyBorder(0, borderColor: .clear)
        
        self.internationView.backgroundColor = .clear
        self.internationView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.currentCategory = "Domestic"
        self.ProgressViewShow(uiView: self.view)
        fetchFinishedMatches()
    }
    
    @IBAction func internationalTapped(_ sender: UIButton) {
        self.internationView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
        self.internationView.applyBorder(0, borderColor: .clear)
        
        self.domesticView.backgroundColor = .clear
        self.domesticView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.currentCategory = "International"
        self.ProgressViewShow(uiView: self.view)
        fetchFinishedMatches()
    }
    
}

extension FinishedVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if matchesFinished.isEmpty == true {
            matchCollectionView.isHidden = true
            emptyImg.isHidden = false
        } else {
            matchCollectionView.isHidden = false
            emptyImg.isHidden = true
        }
        return matchesFinished.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let match = matchesFinished[indexPath.row]
        
        if match.l_id == "NativeAD" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowNativeHome", for: indexPath) as! ShowNativeHome
            
            self.googleNativeAds.googleNativeAdsCustomeView5.isHidden = true
            
            if let adView = Bundle.main.loadNibNamed("SkeletonCustomView5", owner: self, options: nil)?.first as? SkeletonCustomView5 {
                // Add the custom UIView to the adContainerView
                cell.viewForNative.addSubview(adView)
                
                // Set constraints to make sure the adView fills the adContainerView
                adView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    adView.topAnchor.constraint(equalTo: cell.viewForNative.topAnchor),
                    adView.leadingAnchor.constraint(equalTo: cell.viewForNative.leadingAnchor),
                    adView.trailingAnchor.constraint(equalTo: cell.viewForNative.trailingAnchor),
                    adView.bottomAnchor.constraint(equalTo: cell.viewForNative.bottomAnchor)
                ])
                adView.view1.showAnimatedGradientSkeleton()
                adView.view2.showAnimatedGradientSkeleton()
                adView.view3.showAnimatedGradientSkeleton()
                adView.view4.showAnimatedGradientSkeleton()
                adView.view5.showAnimatedGradientSkeleton()
                
            }
            DispatchQueue.main.async {
                if Subscribe.get() == false {
                    self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                        print(" Home...Load Native ....")
                        NativeFailedToLoad = false
                        cell.viewForNative.isHidden = false
                        //                            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        for subview in cell.viewForNative.subviews {
                            if let adView = subview as? SkeletonCustomView5 {
                                self.googleNativeAds.googleNativeAdsCustomeView5.isHidden = true
                                adView.removeFromSuperview()

                            }
                        }
                        DispatchQueue.main.async {
                            self.googleNativeAds.showAdsView5(nativeAd: nativeAdsTemp, view: cell.viewForNative)
                            self.googleNativeAds.googleNativeAdsCustomeView5.isHidden = false
                        }
                    }
                    
                    self.googleNativeAds.failAds(self) { fail in
                        print(" Home...Native fail....")
                        NativeFailedToLoad = true
                        cell.viewForNative.isHidden = true
                    }
                    
                } else {
                    for subview in cell.viewForNative.subviews {
                        if let adView = subview as? SkeletonCustomView5 {
                            self.googleNativeAds.googleNativeAdsCustomeView5.isHidden = true
                            adView.removeFromSuperview()
                        }
                    }
                    NativeFailedToLoad = true
                    cell.viewForNative.isHidden = true
                }
            }
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FinishedCell", for: indexPath) as! FinishedCell
            cell.finishedView.isHidden = false
            cell.finishedHeight.constant = 35
            cell.lblTitle.text = match.m_name
            cell.resultLbl.text = match.result_str
            cell.lblTeam1.text = match.t1_sname
            cell.lblTeam2.text = match.t2_sname
            
            if match.t1_flag == "" {
                cell.img1.image = UIImage(named: "DefaultFlag")!
            } else {
                let urlA = URL(string: match.t1_flag)
                cell.img1.sd_setImage(with: urlA, placeholderImage: UIImage(named: "DefaultFlag"))
            }
            
            if match.t2_flag == "" {
                cell.img2.image = UIImage(named: "DefaultFlag")!
            } else {
                let urlB = URL(string: match.t2_flag)
                cell.img2.sd_setImage(with: urlB, placeholderImage: UIImage(named: "DefaultFlag"))
            }
            
            let result = convertTimestamp(match.strt_time_ts)
            cell.lblDate.text = "\(result.formattedDate) at \(result.formattedTime)"
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let match = matchesFinished[indexPath.row]
        if match.l_id == "NativeAD" {
        } else {
            AdsManager.shared.ShowInterstitialAD {}
            UpComing = false
            let match = matchesFinished[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScoreVC") as! ScoreVC
            vc.l_idMain = match.l_id
            vc.m_idMain = match.m_id
            vc.m_name = match.m_name
            vc.Aimg = match.t1_flag
            vc.Bimg = match.t2_flag
            vc.Aname = match.t1_sname
            vc.Bname = match.t2_sname
            vc.isMatchLive = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let match = matchesFinished[indexPath.row]
        if match.l_id == "NativeAD" {
            if Subscribe.get() == true || nativeId == "" || nativeId == "ca" || NativeFailedToLoad {
                return CGSize(width: collectionView.frame.width - 24, height: 0)
            }else {
                return CGSize(width: collectionView.frame.size.width - 24, height: 205)
            }
        }
        return CGSize(width: collectionView.frame.size.width - 24, height: 205)
    }
    
    // Add the header view for the section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath)
            
            // Add `viewForNative` to the header
            headerView.subviews.forEach { $0.removeFromSuperview() } // Clear any old subviews
            //            if traitCollection.userInterfaceStyle == .dark {
            //                headerView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.40)
            //            } else {
            headerView.backgroundColor = #colorLiteral(red: 0.5960784314, green: 0.6823529412, blue: 0.7019607843, alpha: 1)
            //            }
            viewForNative.frame = headerView.bounds
            headerView.addSubview(viewForNative)
            
            // Set constraints for `viewForNative` to fit the header view
            viewForNative.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                viewForNative.topAnchor.constraint(equalTo: headerView.topAnchor),
                viewForNative.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                viewForNative.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                viewForNative.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
            ])
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    // Define the size for the header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if Subscribe.get() == true || nativeId == "" || nativeId == "ca" {
            return CGSize(width: collectionView.frame.width, height: 0)
        }
        return CGSize(width: collectionView.frame.width, height: 200)
    }
}

extension FinishedVC {
    
    func fetchFinishedMatches() {
        self.matchesFinished.removeAll()
        let url = URL(string: resultMatchAPI)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = ["spt_typ": 2]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                return
            }
            self.parseJSONUpcomimg(data: data)
        }
        task.resume()
    }
    
    func parseJSONUpcomimg(data: Data) {
        do {
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let status = json["status"] as? Bool, status else {
                    print("Status is not true")
                    self.ProgressViewHide(uiView: self.view)
                    return
                }
                
                if let result = json["result"] as? [[String: Any]] {
                    for categoryData in result {
                        if let category = categoryData["category"] as? String, category == self.currentCategory {
                            if let leaguesData = categoryData["data"] as? [[String: Any]] {
                                for leagueData in leaguesData {
                                    let l_id = leagueData["l_id"] as? String ?? ""
                                    if let matchesData = leagueData["matches"] as? [[String: Any]] {
                                        for matchData in matchesData {
                                            if let m_name = matchData["m_name"] as? String,
                                               let result_str = matchData["result_str"] as? String,
                                               let t1_sname = matchData["t1_sname"] as? String,
                                               let t2_sname = matchData["t2_sname"] as? String,
                                               let t1_flag = matchData["t1_flag"] as? String,
                                               let t2_flag = matchData["t2_flag"] as? String,
                                               let t1_goal = matchData["t1_goal"] as? Int,
                                               let t2_goal = matchData["t2_goal"] as? Int,
                                               let strt_time_ts = matchData["strt_time_ts"] as? Int,
                                               let gameState = matchData["gameState"] as? String,
                                               let time = matchData["time"] as? String,
                                               let m_id = matchData["m_id"] as? String{
                                                let match = MatchFinished(m_name: m_name, result_str: result_str, t1_sname: t1_sname, t2_sname: t2_sname, t1_flag: t1_flag, t2_flag: t2_flag, t1_goal: t1_goal, t2_goal: t2_goal, strt_time_ts: strt_time_ts, gameState: gameState, time: time, m_id: m_id, l_id: l_id)
                                                self.matchesFinished.append(match)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.sortMatchesFinished()
                    }
                    
                }
            }
            
        } catch let parsingError {
            print("Parsing Error: \(parsingError)")
        }
        
    }
    
    func sortMatchesFinished() {
        matchesFinished.sort(by: isAscending ? (<) : (>))
        matchesFinished = self.createLiveArrayWithAds()
        self.matchCollectionView.reloadData()
        if self.matchesFinished.count > 0 {
            self.matchCollectionView.setContentOffset(.zero, animated: true)
        }
        self.ProgressViewHide(uiView: self.view)
    }
    
    func createLiveArrayWithAds() -> [MatchFinished] {
        var modifiedArray: [MatchFinished] = []
        var adCount = 0
        
        for match in matchesFinished {
            if adCount == 4 {
                let adModel = MatchFinished(m_name: "", result_str: "", t1_sname: "", t2_sname: "", t1_flag: "", t2_flag: "", t1_goal: 0, t2_goal: 0, strt_time_ts: 0, gameState: "", time: "", m_id: "", l_id: "NativeAD")
                modifiedArray.append(adModel)
                adCount = 0
            }
            modifiedArray.append(match)
            adCount += 1
        }
        
        return modifiedArray
    }
}

