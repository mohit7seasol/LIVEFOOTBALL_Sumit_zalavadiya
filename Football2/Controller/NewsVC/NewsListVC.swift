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
    
    var topNewsPosts: [Post] = [] // First post of each category
    var newsData: News?
    var newsResults: [Result] = []
    var selectedPosts: [Post] = []
    var selectedCategoryIndex = 0
    var index = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .News)
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
        if collectionView == newsCategoryCollectionView {
            if newsResults.count < 1 {
                self.newsCategoryCollectionView.isHidden = true
                self.pageControl.isHidden = true
                self.emptyImg.isHidden = false
            } else {
                self.newsCategoryCollectionView.isHidden = false
                self.pageControl.isHidden = false
                self.emptyImg.isHidden = true
            }
            return newsResults.count
        } else if collectionView == topNewsCollectionView {
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
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == newsCategoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCategoryCell", for: indexPath) as! NewsCategoryCell
            let category = newsResults[indexPath.row]
            cell.categoryLbl.text = category.title
            if selectedCategoryIndex == indexPath.row{
                cell.customView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
                cell.customView.applyBorder(0, borderColor: .clear)
            } else {
                cell.customView.backgroundColor = .clear
                cell.customView.applyBorder(1, borderColor: UIColor(hex: "#314D5B")!)
            }
            
            return cell
        } else if collectionView == topNewsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopNewsCell", for: indexPath) as! TopNewsCell
            let post = topNewsPosts[indexPath.row]
            
            cell.titleLbl.text = post.title
            
            if let imageURL = URL(string: post.media.thumbSrc) {
                cell.iconImg.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "DefaultNews2"))
            }
            
            let timestampString = String(post.updatedAt)
            if let date = convertTimestampToDate(timestampString: timestampString) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d'\(daySuffix(for: date))' MMM yyyy, h:mm a"
                let formattedDate = dateFormatter.string(from: date)
                cell.dateLbl.text = formattedDate
                print("Formatted Date: \(formattedDate)")
            } else {
                cell.dateLbl.text = timestampString
                print("Invalid timestamp format")
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == newsCategoryCollectionView {
            selectedCategoryIndex = indexPath.row
            let posts = newsResults[indexPath.row].posts
            selectedPosts = posts.count > 1 ? Array(posts.dropFirst()) : []
            newsCategoryCollectionView.reloadData()
            newsListTableView.reloadData()
            newsCategoryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            AdsManager.shared.showInterstitialAd()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.selectedNews = topNewsPosts[indexPath.row]
            vc.currentCategory = newsResults[self.selectedCategoryIndex].title
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == newsCategoryCollectionView {
            return CGSize(width: 150, height: 40)
        } else if collectionView == topNewsCollectionView {
            return CGSize(width: collectionView.frame.size.width - 10, height: 286)
        } else {
            return CGSize(width: 0, height: 0)
        }
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
        if selectedPosts.count < 1 {
            self.newsListTableView.isHidden = true
            self.emptyImg.isHidden = false
        } else {
            self.newsListTableView.isHidden = false
            self.emptyImg.isHidden = true
        }
        return selectedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        let post = selectedPosts[indexPath.row]
        
        cell.titleLbl.text = post.title
        
        if let imageURL = URL(string: post.media.thumbSrc) {
            cell.iconImg.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "DefaultNews1"))
        }
        
        let timestampString = String(post.updatedAt)
        if let date = convertTimestampToDate(timestampString: timestampString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d'\(daySuffix(for: date))' MMM yyyy, h:mm a"
            let formattedDate = dateFormatter.string(from: date)
            cell.dateLbl.text = formattedDate
            print("Formatted Date: \(formattedDate)")
        } else {
            cell.dateLbl.text = timestampString
            print("Invalid timestamp format")
        }
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.newsListTableView.contentSize.height
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AdsManager.shared.showInterstitialAd()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
        vc.selectedNews = self.selectedPosts[indexPath.row]
        vc.currentCategory = self.newsResults[self.selectedCategoryIndex].title
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

//MARK: - News API Call
extension NewsListVC
{
    func callNewsAPI() {
        let url = "https://apis.sportstiger.com/Prod/news-home-category-posts"
        let parameters: [String: Any] = [
            "page": 1,
            "limit": 5,
            "postLimit": 15
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: News.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    print("✅ API Call Success")
                    self.newsData = apiResponse
                    self.newsResults = apiResponse.result
                    self.updateUI()
                    WebServices().ProgressViewHide(uiView: self.view ?? UIView())
                case .failure(let error):
                    print("❌ API Call Failed: \(error.localizedDescription)")
                    WebServices().ProgressViewHide(uiView: self.view ?? UIView())
                }
            }
    }
    
    func updateUI() {
        topNewsPosts = newsResults.compactMap { $0.posts.first }
        
        if !newsResults.isEmpty {
            selectedPosts = Array(newsResults[selectedCategoryIndex].posts.dropFirst())
        }
        
        
        pageControl.numberOfPages = topNewsPosts.count
        pageControl.currentPage = 0
        
        topNewsCollectionView.reloadData()
        newsCategoryCollectionView.reloadData()
        newsListTableView.reloadData()
    }
}
