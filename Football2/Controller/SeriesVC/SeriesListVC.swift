//
//  SeriesListVC.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import UIKit
import SVProgressHUD

class SeriesListVC: UIViewController {

    @IBOutlet weak var seriesLbl: UILabel!
    @IBOutlet weak var nativeAdView: View!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var googleNativeAds = GoogleNativeAds()
    var countries: [SeriesCountry] = []
    var index = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: AnalyticEvent.Series)
        setupCollectionView()
        fetchSeriesCountries()
        self.showAd()
    }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "SeriesCountryListCell", bundle: nil), forCellWithReuseIdentifier: "SeriesCountryListCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
        }
    }
    
    // MARK: - API Call for Series Countries
    func fetchSeriesCountries() {
        SVProgressHUD.show()
        
        guard let url = URL(string: "https://flashscore4.p.rapidapi.com/api/flashscore/v2/general/countries?sport_id=1") else {
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
            self?.parseCountryJSON(data: data)
        }.resume()
    }
    
    func parseCountryJSON(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                self.countries.removeAll()
                
                for item in json {
                    let name = item["name"] as? String ?? ""
                    let id = item["country_id"] as? Int ?? 0
                    let countryUrl = item["country_url"] as? String ?? ""
                    
                    let country = SeriesCountry(name: name, countryId: id, country_url: countryUrl)
                    self.countries.append(country)
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
            print("Country JSON Error:", error)
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
                    self.googleNativeAds.showAdsView6(nativeAd: nativeAdsTemp, view: self.nativeAdView)
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
extension SeriesListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeriesCountryListCell", for: indexPath) as! SeriesCountryListCell
        
        let country = countries[indexPath.row]
        cell.countryNameLabel.text = country.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showInterAd()
        let selectedCountry = countries[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: "TournamentsListVC") as! TournamentsListVC
        vc.currentCountryId = selectedCountry.countryId
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 30 // 15 left + 15 right
        let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 100 : 60
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

// MARK: - Button Actions
extension SeriesListVC {
    @IBAction func clickOnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
