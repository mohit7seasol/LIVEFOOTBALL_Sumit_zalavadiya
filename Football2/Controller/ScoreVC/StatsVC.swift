//
//  StatsVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

class StatsVC: UIViewController {
    
    @IBOutlet weak var teamALbl: UILabel!
    @IBOutlet weak var teamBLbl: UILabel!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var statusTableView: UITableView! {
        didSet {
            self.statusTableView.register(UINib.init(nibName: "StatsCell", bundle: nil), forCellReuseIdentifier: "StatsCell")
            statusTableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    
    var stats: [MatchStatModel] = []
    var index = -1
    var m_id: String?
    var l_id: String?
    var matchDetails: MatchDetails?  // Add this to receive team names
    var refreshTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTeamNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !stats.isEmpty {
            updateUIWithStats()
        } else {
            fetchMatchStats()
        }
        startAutoRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func setupTeamNames() {
        // Set team names from matchDetails (passed from ScoreVC)
        if let details = matchDetails {
            teamALbl.text = details.homeName
            teamBLbl.text = details.awayName
        } else {
            // Fallback to placeholder names
            teamALbl.text = "Home Team"
            teamBLbl.text = "Away Team"
        }
    }
    
    func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.fetchMatchStats()
        }
    }
    
    func updateUIWithStats() {
        DispatchQueue.main.async {
            if self.stats.isEmpty {
                self.statusTableView.isHidden = true
                self.tableHeaderView.isHidden = true
                self.emptyImg.isHidden = false
            } else {
                self.statusTableView.isHidden = false
                self.tableHeaderView.isHidden = false
                self.emptyImg.isHidden = true
                self.statusTableView.reloadData()
            }
        }
    }
    
    // MARK: - API Method
    func fetchMatchStats() {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/match/stats?match_id=\(m_id ?? "")"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else { return }
            
            // Debug: Print the response to understand structure
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Stats API Response: \(jsonString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    // The stats are inside "match" key for full match stats
                    var statsArray: [[String: Any]] = []
                    
                    if let matchStats = json["match"] as? [[String: Any]] {
                        statsArray = matchStats
                    } else if let matchStats = json["1st-half"] as? [[String: Any]] {
                        statsArray = matchStats
                    } else if let matchStats = json["2nd-half"] as? [[String: Any]] {
                        statsArray = matchStats
                    }
                    
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
                        self?.stats = temp
                        self?.updateUIWithStats()
                    }
                }
            } catch {
                print("Error parsing stats:", error)
            }
        }.resume()
    }
}

extension StatsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath) as! StatsCell
        cell.selectionStyle = .none
        let stat = stats[indexPath.row]
        cell.lblActions.text = stat.name
        cell.lblTeam1.text = stat.home
        cell.lblTeam2.text = stat.away
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
