//
//  TournamentsListVC.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import UIKit
import SVProgressHUD

class TournamentsListVC: UIViewController {
    @IBOutlet weak var nativeAdView: View!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tournamentLabel: UILabel!
    
    var googleNativeAds = GoogleNativeAds()
    var currentCountryId: Int = 0
    var tournaments: [Tournament] = []
    
    var gradientColorSets = [ #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1), #colorLiteral(red: 0.003921568627, green: 0.7411764706, blue: 0.8039215686, alpha: 1), #colorLiteral(red: 0.3058823529, green: 0.6274509804, blue: 0.9137254902, alpha: 1), #colorLiteral(red: 0.4431372549, green: 0.4156862745, blue: 0.8470588235, alpha: 1) ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: AnalyticEvent.Series)
        setupCollectionView()
        fetchTournaments()
        self.showAd()
    }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "TournamentsListCell", bundle: nil), forCellWithReuseIdentifier: "TournamentsListCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    
    // MARK: - API Call for Tournaments
    func fetchTournaments() {
        SVProgressHUD.show()
        
        guard let url = URL(string: "https://flashscore4.p.rapidapi.com/api/flashscore/v2/general/tournaments?country_id=\(currentCountryId)&sport_id=1") else {
            SVProgressHUD.dismiss()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                return
            }
            self?.parseTournamentJSON(data: data)
        }.resume()
    }
    
    func parseTournamentJSON(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                tournaments.removeAll()
                
                for item in json {
                    let name = item["name"] as? String ?? ""
                    let url = item["tournament_url"] as? String ?? ""
                    
                    let tournament = Tournament(name: name, url: url)
                    tournaments.append(tournament)
                }
                
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.collectionView.reloadData()
                }
            }
        } catch {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            print("Tournament JSON Error:", error)
        }
    }
    
    func showAd() {
        self.showSkeleton()
        if isUserSubscribe() == false {
            self.nativeAdView.showAnimatedSkeleton()
            self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                self.nativeAdView.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.hideSkeleton()
                    self.googleNativeAds.showAdsView3(nativeAd: nativeAdsTemp, view: self.nativeAdView)
                }
            }
            self.googleNativeAds.failAds(self) { fail in
                print(" Home...Native fail....")
                self.nativeAdView.isHidden = true
            }
        } else {
            self.hideSkeleton()
            self.nativeAdView.isHidden = true
        }
    }
    
    func showSkeleton() {
        if let adView = Bundle.main.loadNibNamed("SkeletonCustomView3", owner: self, options: nil)?.first as? SkeletonCustomView3 {
            self.nativeAdView.addSubview(adView)
            
            adView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: self.nativeAdView.topAnchor),
                adView.leadingAnchor.constraint(equalTo: self.nativeAdView.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: self.nativeAdView.trailingAnchor),
                adView.bottomAnchor.constraint(equalTo: self.nativeAdView.bottomAnchor)
            ])
            adView.view1.showAnimatedGradientSkeleton()
            adView.view2.showAnimatedGradientSkeleton()
            adView.view3.showAnimatedGradientSkeleton()
            adView.view4.showAnimatedGradientSkeleton()
            adView.view5.showAnimatedGradientSkeleton()
        }
    }
    
    func hideSkeleton() {
        for subview in self.nativeAdView.subviews {
            if let adView = subview as? SkeletonCustomView3 {
                adView.removeFromSuperview()
            }
        }
    }
}

// MARK: - CollectionView Delegate & DataSource
extension TournamentsListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tournaments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TournamentsListCell", for: indexPath) as! TournamentsListCell
        
        let tournament = tournaments[indexPath.row]
        cell.tournamentNameLabel.text = tournament.name
        
        // Apply random gradient color
        let gradientIndex = indexPath.row % gradientColorSets.count
        cell.applyGradient(color: gradientColorSets[gradientIndex])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        showInterAd()
        let tournament = tournaments[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: "TournamentsMatchesListVC") as! TournamentsMatchesListVC
        vc.tournamentURL = tournament.url
        vc.titleName = tournament.name
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        let spacing: CGFloat = 12
        let inset = collectionView.contentInset.left + collectionView.contentInset.right
        
        let itemsPerRow: CGFloat = isPad ? 4 : 2
        
        let totalSpacing = (itemsPerRow - 1) * spacing
        let availableWidth = collectionView.bounds.width - inset - totalSpacing
        
        let width = floor(availableWidth / itemsPerRow)
        
        return CGSize(width: width, height: isPad ? 140 : 120)
    }
    
}

// MARK: - Button Actions
extension TournamentsListVC {
    @IBAction func backButtonTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
