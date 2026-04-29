//
//  SeriesVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit

struct MatchInfoSeries: Codable {
    let venue: String
    let m_name: String
    let l_name: String
}

struct MatchSeries: Codable {
    let l_id: String
    let show_series_section: Bool
    let cat: String
    let m_id: String
    let m_name: String
    let strt_time_ts: Int
    let strt_time: String
    let t1_name: String
    let t1_id: String
    let t1_sname: String
    let t1_flag: String
    let t2_id: String
    let t2_name: String
    let t2_sname: String
    let t2_flag: String
    let pos: Int
    let slug: String
    let series_slug: String
    let match_info: MatchInfoSeries
}

struct LeagueSeries: Codable {
    let l_id: String
    let series_slug: String
    let l_name: String
    let show_series_section: Bool
    let matches: [MatchSeries]
}

struct MatchesDataSeries: Codable {
    let date: String
    let leagues: [LeagueSeries]
}

struct CategoryDataSeries: Codable {
    let category: String
    let position: Int
}

struct ResultDataSeries: Codable {
    let categoryData: [CategoryDataSeries]
    let matchesData: [MatchesDataSeries]
}

struct APIResponseSeries: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let result: ResultDataSeries
}

class SeriesVC: UIViewController {

    @IBOutlet weak var domesticView: CustomView!
    @IBOutlet weak var internationalView: CustomView!
    @IBOutlet weak var clubView: CustomView!
    @IBOutlet weak var seriesListTableView: UITableView! {
        didSet{
            self.seriesListTableView.register(UINib.init(nibName: "SeriesListCell", bundle: nil), forCellReuseIdentifier: "SeriesListCell")
        }
    }
    @IBOutlet weak var emtyImg: UIImageView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var viewForNative: UIView!
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var index = -1
    
    var matchesData: [MatchesDataSeries] = []
    var sortedDates: [String] = []
    var currentCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .SeriesMatches)
        
        self.domesticView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
        self.domesticView.applyBorder(0, borderColor: .clear)
        
        self.internationalView.backgroundColor = .clear
        self.internationalView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.clubView.backgroundColor = .clear
        self.clubView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.currentCategory = "Domestic"
        fetchSeries()
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
    
    @IBAction func domesticTapped(_ sender: UIButton) {
        self.domesticView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
        self.domesticView.applyBorder(0, borderColor: .clear)
        
        self.internationalView.backgroundColor = .clear
        self.internationalView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.clubView.backgroundColor = .clear
        self.clubView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.currentCategory = "Domestic"
        fetchSeries()
    }
    
    @IBAction func internationalTapped(_ sender: UIButton) {
        self.internationalView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
        self.internationalView.applyBorder(0, borderColor: .clear)
        
        self.domesticView.backgroundColor = .clear
        self.domesticView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.clubView.backgroundColor = .clear
        self.clubView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.currentCategory = "International"
        fetchSeries()
    }
    
    @IBAction func clubTapped(_ sender: UIButton) {
        self.clubView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
        self.clubView.applyBorder(0, borderColor: .clear)
        
        self.domesticView.backgroundColor = .clear
        self.domesticView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.internationalView.backgroundColor = .clear
        self.internationalView.applyBorder(1, borderColor: #colorLiteral(red: 0.1921568627, green: 0.3019607843, blue: 0.3568627451, alpha: 1))
        
        self.currentCategory = "Club Football"
        fetchSeries()
    }
    
}

extension SeriesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if matchesData.isEmpty == true {
            seriesListTableView.isHidden = true
            emtyImg.isHidden = false
        } else {
            seriesListTableView.isHidden = false
            emtyImg.isHidden = true
        }
        
        return matchesData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchesData[section].leagues.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = matchesData[section].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "MM-dd-yyyy"
            return dateFormatter.string(from: date)
        }
        return date
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.003921568627, green: 0.8235294118, blue: 0.3450980392, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        let dates = matchesData[section].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dates) else {
            fatalError("Invalid date format")
        }
        dateFormatter.dateFormat = "dd MMM, yyyy"
        let formattedDateString = dateFormatter.string(from: date)
        
        label.text = formattedDateString
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeriesListCell", for: indexPath) as! SeriesListCell
        cell.selectionStyle = .none
        let league = matchesData[indexPath.section].leagues[indexPath.row]
        let dates = matchesData[indexPath.section].date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dates) else {
            fatalError("Invalid date format")
        }
        dateFormatter.dateFormat = "EEEE, dd MMM"
        let formattedDateString = dateFormatter.string(from: date)
        cell.dateLbl.text = formattedDateString
        
        cell.titleLbl.text = league.l_name
        DispatchQueue.main.async {
            self.tableHeight.constant = self.seriesListTableView.contentSize.height
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AdsManager.shared.showInterstitialAd()
        let league = matchesData[indexPath.section].leagues[indexPath.row]
//        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SeriesMatchVC") as! SeriesMatchVC
            vc.league = league
            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
}

//MARK: - Series API Call
extension SeriesVC {
    
    func fetchSeries() {
        self.ProgressViewShow(uiView: self.view)
        let url = URL(string: seriesMatchAPI)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "spt_typ": 2,
            "category": self.currentCategory,
            "limit": 30,
            "filter_date": "",
            "l_id": "",
            "team_id": ""
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                return
            }
            self.parseJSON(data: data)
        }
        task.resume()
    }
    
    func parseJSON(data: Data) {
        do {
            let apiResponse = try JSONDecoder().decode(APIResponseSeries.self, from: data)
            guard apiResponse.status else {
                self.ProgressViewHide(uiView: self.view)
                print("Status is not true")
                return
                
            }
            self.matchesData = apiResponse.result.matchesData
            DispatchQueue.main.async {
                self.ProgressViewHide(uiView: self.view)
                self.seriesListTableView.reloadData()
            }
        } catch {
            self.ProgressViewHide(uiView: self.view)
            print("Parsing Error: \(error)")
        }
    }
    
    func formatDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func formatTimestamp(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}
