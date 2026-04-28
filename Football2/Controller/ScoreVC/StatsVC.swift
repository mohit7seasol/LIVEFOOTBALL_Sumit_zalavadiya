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
    var refreshTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: - Updated API from Reference Code
    func fetchMatchStats() {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/match/stats?match_id=\(m_id ?? "")"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else { return }
            
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
                        self?.stats = temp
                        self?.updateUIWithStats()
                    }
                }
            } catch {
                print(error)
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
        
        let homeValue = Float(stat.home) ?? 0
        let awayValue = Float(stat.away) ?? 0
        let total = homeValue + awayValue
        
        if total > 0 {
//            cell.progressViewTeam1.progress = homeValue / total
//            cell.progressViewTeam2.progress = awayValue / total
        } else {
//            cell.progressViewTeam1.progress = 0.5
//            cell.progressViewTeam2.progress = 0.5
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
