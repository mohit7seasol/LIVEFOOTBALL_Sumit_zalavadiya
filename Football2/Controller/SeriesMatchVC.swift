//
//  SeriesMatchVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

class SeriesMatchVC: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var seriesMatchCollectionView: UICollectionView! {
        didSet {
            seriesMatchCollectionView.register(UINib(nibName: "FinishedCell", bundle: nil), forCellWithReuseIdentifier: "FinishedCell")
            seriesMatchCollectionView.register(UINib(nibName: "ShowNativeHome", bundle: nil), forCellWithReuseIdentifier: "ShowNativeHome")
            seriesMatchCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    
    var viewForNative = UIView()
    var nativeRealod:Bool = false
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var league: LeagueSeries?
    var modifiedMatches: [MatchSeries] = []
    
    var titleName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewForNative = UIView()
        viewForNative.backgroundColor = .clear
        
        self.titleLbl.text = self.league?.l_name
        
        if (self.league?.matches.count)! < 1 {
            modifiedMatches = self.league?.matches ?? []
            self.seriesMatchCollectionView.isHidden = true
            self.emptyImg.isHidden = false
        } else {
            if let matches = league?.matches {
                modifiedMatches = createSeriesMatchesWithAds(from: matches)
            }
            self.seriesMatchCollectionView.isHidden = false
            self.emptyImg.isHidden = true
        }
        
        subscribe()
    }
    
    func createSeriesMatchesWithAds(from matches: [MatchSeries]) -> [MatchSeries] {
        var modifiedArray: [MatchSeries] = []
        var adCount = 0
        
        for match in matches {
            if adCount == 4 {
                // Create a dummy MatchSeries for the ad
                let adMatch = MatchSeries(
                    l_id: "NativeAD",
                    show_series_section: false,
                    cat: "",
                    m_id: "",
                    m_name: "",
                    strt_time_ts: 0,
                    strt_time: "",
                    t1_name: "",
                    t1_id: "",
                    t1_sname: "",
                    t1_flag: "",
                    t2_id: "",
                    t2_name: "",
                    t2_sname: "",
                    t2_flag: "",
                    pos: 0,
                    slug: "",
                    series_slug: "",
                    match_info: MatchInfoSeries(venue: "", m_name: "", l_name: "")
                )
                modifiedArray.append(adMatch)
                adCount = 0
            }
            
            modifiedArray.append(match)
            adCount += 1
        }
        
        return modifiedArray
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
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension SeriesMatchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modifiedMatches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let match = modifiedMatches[indexPath.row]
        
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
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FinishedCell", for: indexPath) as! FinishedCell
            
            if match.match_info.l_name.isEmpty == true {
                self.titleLbl.text = "Series Matches"
            } else {
                self.titleLbl.text = match.match_info.l_name
            }
            cell.finishedView.isHidden = true
            cell.finishedHeight.constant = 0
            
            cell.lblTitle.text = match.m_name
            cell.resultLbl.text = match.match_info.venue
            
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
        let match = modifiedMatches[indexPath.row]
        if match.l_id == "NativeAD" {
        } else {
            AdsManager.shared.ShowInterstitialAD {}
            UpComing = true
            let match = modifiedMatches[indexPath.row]
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
        let match = modifiedMatches[indexPath.row]
        if match.l_id == "NativeAD" {
            if Subscribe.get() == true || nativeId == "" || nativeId == "ca" || NativeFailedToLoad {
                return CGSize(width: collectionView.frame.width - 24, height: 0)
            }else {
                return CGSize(width: collectionView.frame.size.width - 24, height: 190)
            }
        }
        return CGSize(width: collectionView.frame.size.width - 24, height: 190)
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
