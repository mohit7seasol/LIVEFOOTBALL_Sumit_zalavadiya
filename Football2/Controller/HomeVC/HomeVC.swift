//
//  HomeVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

struct MatchLiveAll{
    let m_name: String
    let t1_sname: String
    let t2_sname: String
    let t1_flag: String
    let t2_flag: String
    let game_status: String
    let strt_time_ts: Int
    let m_id: String
    let l_id: String
}

extension MatchLiveAll: Comparable {
    
    static func < (lhs: MatchLiveAll, rhs: MatchLiveAll) -> Bool {
        return lhs.strt_time_ts < rhs.strt_time_ts
    }
}

class HomeVC: UIViewController {
    
    @IBOutlet weak var liveLbl: UILabel!
    @IBOutlet weak var liveMatchCollectionView: UICollectionView! {
        didSet {
            liveMatchCollectionView.register(UINib(nibName: "LiveCell", bundle: nil), forCellWithReuseIdentifier: "LiveCell")
            liveMatchCollectionView.register(UINib(nibName: "UpcomingCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingCell")
        }
    }
    @IBOutlet weak var liveEmptyImg: UIImageView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var newsTableView: UITableView! {
        didSet {
            self.newsTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
            self.newsTableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var viewForNative: UIView!
    
    var index = -1
    var matcheslive: [MatchLiveAll] = []
    var isAscending: Bool = true
    var isLiveAvailable: Bool = true
    var matchesUpcoming: [MatchUpcoming] = []
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var newsData: News?
    var newsResults: [Result] = []
    var selectedPosts: [Post] = []
    var selectedCategoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .Home)
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ProgressViewShow(uiView: self.view)
        fetchLiveMatchesDom()
        callNewsAPI()
    }
    
    func subscribe() {
        showSkeletonView()
        if Subscribe.get() == false {
            self.googleNativeAds.loadInlineNativeAds(self) { nativeAdsTemp in
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
    
    @IBAction func liveSeeAllTapped(_ sender: UIButton) {
        AdsManager.shared.ShowInterstitialAD {}
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LiveMatchListVC") as! LiveMatchListVC
        vc.currentSelection = self.isLiveAvailable
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func newsSeeAllTapped(_ sender: UIButton) {
        AdsManager.shared.ShowInterstitialAD {}
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsListVC") as! NewsListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLiveAvailable == false {
            if matchesUpcoming.isEmpty == true {
                liveMatchCollectionView.isHidden = true
                pageControll.isHidden = true
                liveEmptyImg.isHidden = false
            } else {
                liveMatchCollectionView.isHidden = false
                pageControll.isHidden = false
                liveEmptyImg.isHidden = true
            }
            return matchesUpcoming.count
        } else {
            if matcheslive.isEmpty == true {
                liveMatchCollectionView.isHidden = true
                pageControll.isHidden = true
                liveEmptyImg.isHidden = false
            } else {
                liveMatchCollectionView.isHidden = false
                pageControll.isHidden = false
                liveEmptyImg.isHidden = true
            }
            return matcheslive.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isLiveAvailable == false {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingCell", for: indexPath) as! UpcomingCell
            
            let match = matchesUpcoming[indexPath.row]
            
            cell.lblTitle?.text = match.m_name
            
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LiveCell", for: indexPath) as! LiveCell
            
            let match = matcheslive[indexPath.row]
            cell.lblTitle?.text = match.m_name
            
            cell.lblTeam1.text = match.t1_sname
            cell.lblTeam2.text = match.t2_sname
            cell.statusLbl.text = match.game_status
            
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
        AdsManager.shared.ShowInterstitialAD {}
        if self.isLiveAvailable == false {
            UpComing = true
            let match = matchesUpcoming[indexPath.row]
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
        } else {
            UpComing = false
            let match = matcheslive[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScoreVC") as! ScoreVC
            vc.l_idMain = match.l_id
            vc.m_idMain = match.m_id
            vc.m_name = match.m_name
            vc.Aimg = match.t1_flag
            vc.Bimg = match.t2_flag
            vc.Aname = match.t1_sname
            vc.Bname = match.t2_sname
            vc.isMatchLive = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.isLiveAvailable == false {
            return CGSize(width: collectionView.frame.width - 10, height: 164)
        } else {
            return CGSize(width: collectionView.frame.width - 10, height: 205)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x + (scrollView.frame.width / 2)) / scrollView.frame.width)
        pageControll.currentPage = page
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        let post = selectedPosts[indexPath.row]
        
        cell.titleLbl.text = post.title
        
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
        
        if let imageURL = URL(string: post.media.thumbSrc) {
            cell.iconImg.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "DefaultNews1"))
        }
        
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.newsTableView.contentSize.height
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AdsManager.shared.ShowInterstitialAD {}
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

// MARK: - Live Match API Call
extension HomeVC {
    
    func fetchLiveMatchesDom() {
        self.matcheslive.removeAll()
        let url = URL(string: liveMatchAPI)!
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
            self.parseJSONLiveDom(data: data)
        }
        task.resume()
    }
    
    func parseJSONLiveDom(data: Data) {
        
        do {
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let status = json["status"] as? Bool, status else {
                    print("Status is not true")
                    DispatchQueue.main.async {
                        self.isLiveAvailable = false
                        self.liveLbl.text = "Upcoming"
                        self.collectionViewHeight.constant = 164
                        self.fetchUpcomingMatches()
//                        self.ProgressViewHide(uiView: self.view)
                    }
                    return
                }
                
                if let result = json["result"] as? [[String: Any]] {
                    for categoryData in result {
                        if let category = categoryData["category"] as? String {
                            if let leaguesData = categoryData["data"] as? [[String: Any]] {
                                for leagueData in leaguesData {
                                    let l_id = leagueData["l_id"] as? String ?? ""
                                    if let matchesData = leagueData["matches"] as? [[String: Any]] {
                                        for matchData in matchesData {
                                            if let m_name = matchData["m_name"] as? String,
                                               let t1_sname = matchData["t1_sname"] as? String,
                                               let t2_sname = matchData["t2_sname"] as? String,
                                               let t1_flag = matchData["t1_flag"] as? String,
                                               let t2_flag = matchData["t2_flag"] as? String,
                                               let game_status = matchData["gameState"] as? String,
                                               let strt_time_ts = matchData["strt_time_ts"] as? Int,
                                               let m_id = matchData["m_id"] as? String{
                                                let match = MatchLiveAll(m_name: m_name, t1_sname: t1_sname, t2_sname: t2_sname, t1_flag: t1_flag, t2_flag: t2_flag, game_status: game_status, strt_time_ts: strt_time_ts, m_id: m_id, l_id: l_id)
                                                self.matcheslive.append(match)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.sortMatchesLive()
                    }
                }
            }
            
        } catch let parsingError {
            print("Parsing Error: \(parsingError)")
        }
        
    }
    
    func sortMatchesLive() {
        matcheslive.sort(by: isAscending ? (<) : (>))
        self.pageControll.numberOfPages = matcheslive.count
        if self.matcheslive.count < 1 {
            self.isLiveAvailable = false
            self.liveLbl.text = "Upcoming"
            self.collectionViewHeight.constant = 164
            self.fetchUpcomingMatches()
        } else {
            self.isLiveAvailable = true
            self.liveLbl.text = "Live"
            self.collectionViewHeight.constant = 205
            liveMatchCollectionView.delegate = self
            liveMatchCollectionView.dataSource = self
            liveMatchCollectionView.reloadData()
        }
    }
}

//MARK: - Upcoming API Call
extension HomeVC {
    
    func fetchUpcomingMatches() {
        self.matchesUpcoming.removeAll()
        let url = URL(string: upcomingMatchAPI)!
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
                        if let category = categoryData["category"] as? String {
                            if let leaguesData = categoryData["data"] as? [[String: Any]] {
                                for leagueData in leaguesData {
                                    let l_id = leagueData["l_id"] as? String ?? ""
                                    if let matchesData = leagueData["matches"] as? [[String: Any]] {
                                        for matchData in matchesData {
                                            if let m_name = matchData["m_name"] as? String,
                                               let t1_sname = matchData["t1_sname"] as? String,
                                               let t2_sname = matchData["t2_sname"] as? String,
                                               let t1_flag = matchData["t1_flag"] as? String,
                                               let t2_flag = matchData["t2_flag"] as? String,
                                               let strt_time_ts = matchData["strt_time_ts"] as? Int,
                                               let m_id = matchData["m_id"] as? String{
                                                let match = MatchUpcoming(m_name: m_name, t1_sname: t1_sname, t2_sname: t2_sname, t1_flag: t1_flag, t2_flag: t2_flag, strt_time_ts: strt_time_ts, m_id: m_id, l_id: l_id)
                                                self.matchesUpcoming.append(match)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.sortMatchesUpcoming()
                    }
                    
                }
            }
            
        } catch let parsingError {
            print("Parsing Error: \(parsingError)")
        }
        
    }
    
    func sortMatchesUpcoming() {
        matchesUpcoming.sort(by: isAscending ? (<) : (>))
        self.pageControll.numberOfPages = matchesUpcoming.count
        liveMatchCollectionView.delegate = self
        liveMatchCollectionView.dataSource = self
        self.liveMatchCollectionView.reloadData()
        self.ProgressViewHide(uiView: self.view)
    }
}

// MARK: - News API Call
extension HomeVC {
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
                    self.ProgressViewHide(uiView: self.view)
                case .failure(let error):
                    print("❌ API Call Failed: \(error.localizedDescription)")
                    self.ProgressViewHide(uiView: self.view)
                }
            }
    }
    
    func updateUI() {
        if let footballCategory = newsResults.first(where: { $0.title.uppercased() == "FOOTBALL" }) {
            selectedPosts = footballCategory.posts
        } else {
            selectedPosts = []
        }
        
        emptyImg.isHidden = !selectedPosts.isEmpty
        newsTableView.reloadData()
    }
}
