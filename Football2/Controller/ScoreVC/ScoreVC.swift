//
//  ScoreVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit
import MarqueeLabel

class ScoreVC: BaseVC {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var matchTitleLbl: UILabel!
    @IBOutlet weak var viewForUpcomingScore: UIView!
    @IBOutlet weak var viewForOtherScores: UIView!
    
    @IBOutlet weak var imgA: UIImageView!
    @IBOutlet weak var lblA: MarqueeLabel!
    @IBOutlet weak var imgB: UIImageView!
    @IBOutlet weak var lblB: MarqueeLabel!
    
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblComplated: UILabel!
    
    @IBOutlet weak var lblT1Goal: UILabel!
    @IBOutlet weak var lblT1Rflag: UILabel!
    @IBOutlet weak var lblT1Yflag: UILabel!
    @IBOutlet weak var lblT1Kick: UILabel!
    
    @IBOutlet weak var lblT2Kick: UILabel!
    @IBOutlet weak var lblT2Yflag: UILabel!
    @IBOutlet weak var lblT2Rflag: UILabel!
    @IBOutlet weak var lblT2Goal: UILabel!
    
    @IBOutlet weak var topCollectionView: UICollectionView! {
        didSet {
            self.topCollectionView.register(UINib.init(nibName: "NewsCategoryCell", bundle: nil), forCellWithReuseIdentifier: "NewsCategoryCell")
        }
    }
    
    var m_idMain:String?
    var l_idMain:String?
    var m_name:String?
    var Aname:String?
    var Bname:String?
    var Aimg:String?
    var Bimg:String?
    var topArrray : [String] = []
    var index = 0
    var isMatchLive = false
    
    var refreshTimer: Timer?
    
    private var pagerVc: ScorePagerVC?
    
    // Data from APIs
    var matchDetails: MatchDetails?
    var matchStats: [MatchStatModel] = []
    var eventsUpdates: [MatchSummaryEvent] = []
    var standings: [Standing] = []
    var h2hMatches: [H2HMatch] = []
    var lineupData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .MatchDetails)
        self.titleLbl.text = "Match Details"
        
        topArrray = [String.LiveUpdate, String.Overview, String.Lineups, String.Stats, String.HeadToHead, String.Info, String.PointTable]
        viewForUpcomingScore.isHidden = true
        viewForOtherScores.isHidden = false
        
        self.setData()
        DispatchQueue.main.async {
            self.fetchAllMatchData()
            self.topCollectionView.reloadData()
        }
        startAutoRefresh()
    }
    
    func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.setData()
            DispatchQueue.main.async {
                self.fetchMatchDataOnly()
                self.topCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Fetch All Match Data
    func fetchAllMatchData() {
        let dispatchGroup = DispatchGroup()
        
        // 1. Fetch Match Details (Info)
        dispatchGroup.enter()
        fetchMatchDetails { success in
            dispatchGroup.leave()
        }
        
        // 2. Fetch Match Stats
        dispatchGroup.enter()
        fetchMatchStats { success in
            dispatchGroup.leave()
        }
        
        // 3. Fetch Match Summary (Live Update & Overview)
        dispatchGroup.enter()
        fetchMatchSummary { success in
            dispatchGroup.leave()
        }
        
        // 4. Fetch Standings (Point Table)
        dispatchGroup.enter()
        fetchMatchStandings { success in
            dispatchGroup.leave()
        }
        
        // 5. Fetch Head2Head Matches
        dispatchGroup.enter()
        fetchHead2HeadMatches { success in
            dispatchGroup.leave()
        }
        
        // 6. Fetch Lineup Data
        dispatchGroup.enter()
        fetchLineupData { success in
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.updateTitleArrBasedOnAvailableData()
        }
    }
    
    func fetchMatchDataOnly() {
        fetchMatchDetails { _ in }
        fetchMatchSummary { _ in }
        if !UpComing {
            fetchMatchStats { _ in }
        }
    }
}

extension ScoreVC {
    
    func setData() {
        DispatchQueue.main.async {
            if self.m_name?.isEmpty == false {
                self.matchTitleLbl.text = self.m_name
            } else {
                self.matchTitleLbl.text = ""
            }
            
            if self.Aname?.isEmpty == false {
                self.lblA.text = self.Aname
            } else {
                self.lblA.text = "TeamA"
            }
            
            if self.Bname?.isEmpty == false {
                self.lblB.text = self.Bname
            } else {
                self.lblB.text = "TeamB"
            }
            
            if self.Aimg?.isEmpty == false {
                let urlA = URL(string: self.Aimg!)
                self.imgA.sd_setImage(with: urlA, placeholderImage: UIImage(named: "DefaultFlag"))
            } else {
                self.imgA.image = UIImage(named: "DefaultFlag")!
            }
            
            if self.Bimg?.isEmpty == false {
                let urlA = URL(string: self.Bimg!)
                self.imgB.sd_setImage(with: urlA, placeholderImage: UIImage(named: "DefaultFlag"))
            } else {
                self.imgB.image = UIImage(named: "DefaultFlag")!
            }
        }
    }
    
    // MARK: - API Methods (from ScoreDetailsVC)
    
    func fetchMatchDetails(completion: @escaping (Bool) -> Void) {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/details?match_id=\(m_idMain ?? "")"
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    let home = json["home_team"] as? [String: Any]
                    let away = json["away_team"] as? [String: Any]
                    let tournament = json["tournament"] as? [String: Any]
                    let scores = json["scores"] as? [String: Any]
                    let status = json["match_status"] as? [String: Any]
                    let venue = json["venue"] as? [String: Any]
                    
                    let details = MatchDetails(
                        leagueName: tournament?["name"] as? String ?? "",
                        homeName: home?["name"] as? String ?? self?.Aname ?? "",
                        homeShortName: home?["short_name"] as? String ?? "",
                        awayName: away?["name"] as? String ?? self?.Bname ?? "",
                        awayShortName: away?["short_name"] as? String ?? "",
                        homeLogo: home?["image_path"] as? String ?? self?.Aimg ?? "",
                        awayLogo: away?["image_path"] as? String ?? self?.Bimg ?? "",
                        homeScore: scores?["home"] as? Int ?? 0,
                        awayScore: scores?["away"] as? Int ?? 0,
                        status: status?["stage"] as? String ?? "",
                        liveTime: status?["live_time"] as? String ?? "",
                        referee: json["referee"] as? String ?? "",
                        venueName: venue?["name"] as? String ?? "",
                        venueCity: venue?["city"] as? String ?? "",
                        attendance: venue?["attendance"] as? String ?? "",
                        capacity: venue?["capacity"] as? String ?? "",
                        timestamp: json["timestamp"] as? Int ?? 0
                    )
                    
                    DispatchQueue.main.async {
                        self?.matchDetails = details
                        
                        // Update UI with fetched data
                        self?.lblScore.text = "\(details.homeScore) - \(details.awayScore)"
                        self?.matchTitleLbl.text = details.leagueName
                        
                        if !details.liveTime.isEmpty {
                            self?.lblComplated.text = "\(details.liveTime)' Completed"
                        } else if details.status == "Finished" {
                            self?.lblComplated.text = "Completed"
                        } else {
                            self?.lblComplated.text = details.status
                        }
                        
                        // Update team names and images if available
                        if !details.homeName.isEmpty {
                            self?.lblA.text = details.homeName
                        }
                        if !details.awayName.isEmpty {
                            self?.lblB.text = details.awayName
                        }
                        
                        if let url = URL(string: details.homeLogo), !details.homeLogo.isEmpty {
                            self?.imgA.sd_setImage(with: url, placeholderImage: UIImage(named: "DefaultFlag"))
                        }
                        if let url = URL(string: details.awayLogo), !details.awayLogo.isEmpty {
                            self?.imgB.sd_setImage(with: url, placeholderImage: UIImage(named: "DefaultFlag"))
                        }
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print(error)
                completion(false)
            }
        }.resume()
    }
    
    func fetchMatchStats(completion: @escaping (Bool) -> Void) {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/match/stats?match_id=\(m_idMain ?? "")"
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let statsArray = json["match"] as? [[String: Any]] {
                    
                    var temp: [MatchStatModel] = []
                    for s in statsArray {
                        let stat = MatchStatModel(
                            name: s["name"] as? String ?? "",
                            home: "\(s["home_team"] ?? "")",
                            away: "\(s["away_team"] ?? "")"
                        )
                        temp.append(stat)
                    }
                    
                    DispatchQueue.main.async {
                        self?.matchStats = temp
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print(error)
                completion(false)
            }
        }.resume()
    }
    
    func fetchMatchSummary(completion: @escaping (Bool) -> Void) {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/match/summary?match_id=\(m_idMain ?? "")"
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(APITOKEN, forHTTPHeaderField: "x-rapidapi-key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode([MatchSummaryEvent].self, from: data)
                
                DispatchQueue.main.async {
                    self?.eventsUpdates = result
                }
                completion(!result.isEmpty)
            } catch {
                print("Decode error:", error)
                completion(false)
            }
        }.resume()
    }
    
    func fetchMatchStandings(completion: @escaping (Bool) -> Void) {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/standings?type=overall&match_id=\(m_idMain ?? "")"

        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(APITOKEN, forHTTPHeaderField: "x-rapidapi-key")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                let result = try JSONDecoder().decode([Standing].self, from: data)

                DispatchQueue.main.async {
                    self?.standings = result
                    self?.pagerVc?.standings = result
                }

                completion(!result.isEmpty)
            } catch {
                print("Decode error:", error)
                completion(false)
            }
        }.resume()
    }
    
    func fetchHead2HeadMatches(completion: @escaping (Bool) -> Void) {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/h2h?match_id=\(m_idMain ?? "")"
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(APITOKEN, forHTTPHeaderField: "x-rapidapi-key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let allMatches = try JSONDecoder().decode([H2HMatch].self, from: data)
                
                let team1Name = self?.Aname ?? ""
                let team2Name = self?.Bname ?? ""
                
                let filtered = allMatches.filter {
                    let home = $0.home_team?.name?.lowercased() ?? ""
                    let away = $0.away_team?.name?.lowercased() ?? ""
                    let team1 = team1Name.lowercased()
                    let team2 = team2Name.lowercased()
                    
                    return (home.contains(team1) && away.contains(team2)) ||
                           (home.contains(team2) && away.contains(team1))
                }
                
                let sorted = filtered.sorted { ($0.timestamp ?? 0) > ($1.timestamp ?? 0) }
                
                DispatchQueue.main.async {
                    self?.h2hMatches = sorted
                }
                completion(!sorted.isEmpty)
            } catch {
                print("Decode error:", error)
                completion(false)
            }
        }.resume()
    }
    
    func fetchLineupData(completion: @escaping (Bool) -> Void) {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/match/lineups?match_id=\(m_idMain ?? "")"
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(APITOKEN, forHTTPHeaderField: "x-rapidapi-key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Lineup API Error:", error?.localizedDescription ?? "")
                completion(false)
                return
            }
            
            do {
                if let result = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    self?.lineupData = result
                    
                    // Check if we have valid lineup data - need actual players
                    var hasValidData = false
                    
                    if result.count >= 2 {
                        let homeTeam = result[0]
                        let awayTeam = result[1]
                        
                        // Check starting lineups
                        let homeStartingLineups = homeTeam["startingLineups"] as? [[String: Any]] ?? []
                        let awayStartingLineups = awayTeam["startingLineups"] as? [[String: Any]] ?? []
                        
                        // Check predicted lineups
                        let homePredictedLineups = homeTeam["predictedLineups"] as? [[String: Any]] ?? []
                        let awayPredictedLineups = awayTeam["predictedLineups"] as? [[String: Any]] ?? []
                        
                        // Valid data if either starting lineups OR predicted lineups have players
                        let homeHasPlayers = !homeStartingLineups.isEmpty || !homePredictedLineups.isEmpty
                        let awayHasPlayers = !awayStartingLineups.isEmpty || !awayPredictedLineups.isEmpty
                        
                        hasValidData = homeHasPlayers && awayHasPlayers
                        
                        print("Home players count - Starting: \(homeStartingLineups.count), Predicted: \(homePredictedLineups.count)")
                        print("Away players count - Starting: \(awayStartingLineups.count), Predicted: \(awayPredictedLineups.count)")
                        print("Has valid lineup data: \(hasValidData)")
                    }
                    
                    completion(hasValidData)
                } else {
                    self?.lineupData = []
                    completion(false)
                }
            } catch {
                print("Lineup JSON Error:", error)
                self?.lineupData = []
                completion(false)
            }
        }.resume()
    }
    
    func updateTitleArrBasedOnAvailableData() {
        var newArrray: [String] = []
        
        // Add tabs only if data is available
        if !eventsUpdates.isEmpty {
            newArrray.append(String.LiveUpdate)
            newArrray.append(String.Overview)
        }
        
        // Lineups - check if we have valid lineup data with actual players
        var hasValidLineupData = false
        
        if lineupData.count >= 2 {
            let homeTeam = lineupData[0]
            let awayTeam = lineupData[1]
            
            // Check starting lineups
            let homeStartingLineups = homeTeam["startingLineups"] as? [[String: Any]] ?? []
            let awayStartingLineups = awayTeam["startingLineups"] as? [[String: Any]] ?? []
            
            // Check predicted lineups
            let homePredictedLineups = homeTeam["predictedLineups"] as? [[String: Any]] ?? []
            let awayPredictedLineups = awayTeam["predictedLineups"] as? [[String: Any]] ?? []
            
            // Valid data if either starting lineups OR predicted lineups have players
            let homeHasPlayers = !homeStartingLineups.isEmpty || !homePredictedLineups.isEmpty
            let awayHasPlayers = !awayStartingLineups.isEmpty || !awayPredictedLineups.isEmpty
            
            hasValidLineupData = homeHasPlayers && awayHasPlayers
        }
        
        if hasValidLineupData {
            newArrray.append(String.Lineups)
        }
        
        if !matchStats.isEmpty {
            newArrray.append(String.Stats)
        }
        
        if !h2hMatches.isEmpty {
            newArrray.append(String.HeadToHead)
        }
        
        if matchDetails != nil {
            newArrray.append(String.Info)
        }
        
        if !standings.isEmpty {
            newArrray.append(String.PointTable)
        }
        
        // If no data at all, show default tabs
        if newArrray.isEmpty {
            newArrray = [String.LiveUpdate, String.Overview, String.Lineups, String.Stats, String.HeadToHead, String.Info, String.PointTable]
        }
        
        topArrray = newArrray
        print("Available tabs: \(topArrray)")
        
        DispatchQueue.main.async {
            self.topCollectionView.reloadData()
            self.index = 0
            self.topCollectionView.setNeedsLayout()
            
            // Move to first page if pager exists
            if let firstTab = self.topArrray.first {
                switch firstTab {
                case String.LiveUpdate:
                    self.pagerVc?.moveToPage(index: 0, animated: true)
                case String.Overview:
                    self.pagerVc?.moveToPage(index: 1, animated: true)
                case String.Lineups:
                    self.pagerVc?.moveToPage(index: 2, animated: true)
                case String.Stats:
                    self.pagerVc?.moveToPage(index: 3, animated: true)
                case String.HeadToHead:
                    self.pagerVc?.moveToPage(index: 4, animated: true)
                case String.Info:
                    self.pagerVc?.moveToPage(index: 5, animated: true)
                case String.PointTable:
                    self.pagerVc?.moveToPage(index: 6, animated: true)
                default:
                    break
                }
            }
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ScoreVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topArrray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCategoryCell", for: indexPath) as! NewsCategoryCell
        if indexPath.row == index {
            cell.categoryLbl.textColor = #colorLiteral(red: 0.02745098039, green: 0.831372549, blue: 0.3803921569, alpha: 1)
        } else {
            cell.categoryLbl.textColor = #colorLiteral(red: 0.5019999743, green: 0.5839999914, blue: 0.6159999967, alpha: 1)
        }
        cell.categoryLbl.text = topArrray[indexPath.item]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        index = indexPath.row
        collectionView.reloadData()
        
        let selectedTab = topArrray[indexPath.item]
        
        // Pass all data to pager
        pagerVc?.m_idMain = self.m_idMain
        pagerVc?.l_idMain = self.l_idMain
        pagerVc?.Aname = self.Aname
        pagerVc?.Bname = self.Bname
        pagerVc?.Aimg = self.Aimg
        pagerVc?.Bimg = self.Bimg
        pagerVc?.isMatchLive = self.isMatchLive
        pagerVc?.matchDetails = self.matchDetails
        pagerVc?.stats = self.matchStats
        pagerVc?.eventsUpdates = self.eventsUpdates
        pagerVc?.standings = self.standings
        pagerVc?.h2hMatches = self.h2hMatches
        pagerVc?.lineupData = self.lineupData
        
        switch selectedTab {
        case String.LiveUpdate:
            pagerVc?.moveToPage(index: 0, animated: true)
        case String.Overview:
            pagerVc?.moveToPage(index: 1, animated: true)
        case String.Lineups:
            pagerVc?.moveToPage(index: 2, animated: true)
        case String.Stats:
            pagerVc?.moveToPage(index: 3, animated: true)
        case String.HeadToHead:
            pagerVc?.moveToPage(index: 4, animated: true)
        case String.Info:
            pagerVc?.moveToPage(index: 5, animated: true)
        case String.PointTable:
            pagerVc?.moveToPage(index: 6, animated: true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellCount = CGFloat(topArrray.count)
        
        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            let totalCellWidth = cellWidth*cellCount + 20.00 * (cellCount-1)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            if (totalCellWidth < contentWidth) {
                let padding = (contentWidth - totalCellWidth) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            } else {
                return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
        }
        return UIEdgeInsets.zero
    }
}


extension ScoreVC: ScoreOptionDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? ScorePagerVC {
            pagerVc = pageViewController
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
            pagerVc?.Aimg = self.Aimg
            pagerVc?.Bimg = self.Bimg
            pagerVc?.isMatchLive = self.isMatchLive
            pagerVc?.matchDetails = self.matchDetails
            pagerVc?.stats = self.matchStats
            pagerVc?.eventsUpdates = self.eventsUpdates
            pagerVc?.standings = self.standings
            pagerVc?.h2hMatches = self.h2hMatches
            pagerVc?.lineupData = self.lineupData
            pagerVc?.optionDelegate = self
        }
    }
    
    func didUpdateOptionIndex(currentIndex: Int) {
        if currentIndex == 0 {
            pagerVc?.moveToPage(index: 0, animated: true)
        } else if currentIndex == 1 {
            pagerVc?.moveToPage(index: 1, animated: true)
        } else if currentIndex == 2 {
            pagerVc?.moveToPage(index: 2, animated: true)
        } else if currentIndex == 3 {
            pagerVc?.moveToPage(index: 3, animated: true)
        } else if currentIndex == 4 {
            pagerVc?.moveToPage(index: 4, animated: true)
        } else if currentIndex == 5 {
            pagerVc?.moveToPage(index: 5, animated: true)
        } else if currentIndex == 6 {
            pagerVc?.moveToPage(index: 6, animated: true)
        }
    }
}
