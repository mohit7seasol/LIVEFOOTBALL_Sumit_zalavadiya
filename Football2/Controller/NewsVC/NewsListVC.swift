//
//  NewsListVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 29/04/25.
//

import UIKit
import Alamofire

class NewsListVC: UIViewController {
    
    @IBOutlet weak var topNewsCollectionView: UICollectionView! {
        didSet {
            topNewsCollectionView.register(UINib(nibName: "TopNewsCell", bundle: nil), forCellWithReuseIdentifier: "TopNewsCell")
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var newsCategoryCollectionView: UICollectionView! {
        didSet {
            newsCategoryCollectionView.register(UINib(nibName: "NewsCategoryCell", bundle: nil), forCellWithReuseIdentifier: "NewsCategoryCell")
        }
    }
    @IBOutlet weak var newsListTableView: UITableView! {
        didSet {
            self.newsListTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
            self.newsListTableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var viewForNative: UIView!
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var topNewsPosts: [NewsItem] = [] // Top 5 news for banner
    var allNews: [NewsItem] = [] // All news for table view
    var selectedCategoryIndex = 0
    var index = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .News)
        
        // Hide category collection view (as requested)
        newsCategoryCollectionView.isHidden = true
        
        callNewsAPI()
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
                    self.googleNativeAds.showAdsView6(nativeAd: nativeAdsTemp, view: self.viewForNative)
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
        if let adView = Bundle.main.loadNibNamed("SkeletonCustomView3", owner: self, options: nil)?.first as? SkeletonCustomView3 {
            self.viewForNative.addSubview(adView)
            
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
        }
    }
    
    func hideSkeletonView() {
        for subview in self.viewForNative.subviews {
            if let adView = subview as? SkeletonCustomView3 {
                adView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NewsListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topNewsCollectionView {
            if topNewsPosts.count < 1 {
                self.topNewsCollectionView.isHidden = true
                self.pageControl.isHidden = true
                self.emptyImg.isHidden = false
            } else {
                self.topNewsCollectionView.isHidden = false
                self.pageControl.isHidden = false
                self.emptyImg.isHidden = true
            }
            return topNewsPosts.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topNewsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopNewsCell", for: indexPath) as! TopNewsCell
            let news = topNewsPosts[indexPath.row]
            
            cell.titleLbl.text = news.title
            
            if let imageURL = URL(string: news.imageUrl) {
                cell.iconImg.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "DefaultNews2"))
            }
            
            cell.dateLbl.text = ""
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topNewsCollectionView {
            AdsManager.shared.showInterstitialAd()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            let selectedNews = topNewsPosts[indexPath.row]
            
            // Pass data to NewsDetailVC
            vc.selectedNews = selectedNews
            vc.currentCategory = "Football"
            vc.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == topNewsCollectionView {
            return CGSize(width: collectionView.frame.size.width - 10, height: 286)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == topNewsCollectionView {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
            pageControl.currentPage = page
        }
    }
}

extension NewsListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allNews.count < 1 {
            self.newsListTableView.isHidden = true
            self.emptyImg.isHidden = false
        } else {
            self.newsListTableView.isHidden = false
            self.emptyImg.isHidden = true
        }
        return allNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        let news = allNews[indexPath.row]
        
        cell.titleLbl.text = news.title
        cell.descLbl.text = news.subDesc
        
        if let imageURL = URL(string: news.imageUrl) {
            cell.iconImg.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "DefaultNews1"))
        }
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.newsListTableView.contentSize.height
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        AdsManager.shared.showInterstitialAd()
        showInterAd()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
        let selectedNews = allNews[indexPath.row]
        
        // Pass data to NewsDetailVC
        vc.selectedNews = selectedNews
        vc.currentCategory = "Football"
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - News API Call
extension NewsListVC {
    func callNewsAPI() {
        let params: [String: Any] = [
            "category": ["Football"]
        ]
        
        AF.request("https://api-story.7seasol.in/api/fresh-news",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
        .validate(statusCode: 200..<300)
        .responseData { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let data):
                do {
                    // Parse JSON manually to see the structure
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📦 Response JSON: \(json)")
                        
                        if let dataArray = json["data"] as? [[String: Any]] {
                            var newsItems: [NewsItem] = []
                            
                            for item in dataArray {
                                let id = item["id"] as? String ?? ""
                                let title = item["title"] as? String ?? ""
                                let category = item["category"] as? String ?? ""
                                let imageUrl = item["imageUrl"] as? String ?? ""
                                let subDesc = item["subDesc"] as? String ?? ""
                                let article = item["article"] as? String ?? ""
                                
                                // Only include Football category news
                                if category.lowercased() == "football" {
                                    let newsItem = NewsItem(
                                        id: id,
                                        title: title,
                                        category: category,
                                        imageUrl: imageUrl,
                                        subDesc: subDesc,
                                        article: article
                                    )
                                    newsItems.append(newsItem)
                                }
                            }
                            
                            print("✅ Found \(newsItems.count) football news items")
                            
                            // Set top 5 news for banner
                            self.topNewsPosts = Array(newsItems.prefix(5))
                            
                            // Set all news for table view
                            self.allNews = newsItems
                            
                            // Update UI
                            DispatchQueue.main.async {
                                self.pageControl.numberOfPages = self.topNewsPosts.count
                                self.pageControl.currentPage = 0
                                
                                self.topNewsCollectionView.reloadData()
                                self.newsListTableView.reloadData()
                            }
                        } else {
                            print("❌ No data array found in response")
                        }
                    }
                } catch {
                    print("❌ JSON parsing error: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                print("❌ API Call Failed: \(error.localizedDescription)")
            }
        }
    }
}
