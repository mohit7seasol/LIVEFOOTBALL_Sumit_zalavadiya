//
//  StatsVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

struct MatchStat: Codable {
    let typeId: Int
    let t1Stats: Int
    let t2Stats: Int
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case typeId
        case t1Stats = "t1_Stats"
        case t2Stats = "t2_Stats"
        case type
    }
}

struct MatchStatsResponse: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let result: MatchStatsResult?
}

struct MatchStatsResult: Codable {
    let mId: String
    let t1Id: Int
    let t1Name: String
    let t2Id: Int
    let t2Name: String
    let matchStats: [MatchStat]?
    
    enum CodingKeys: String, CodingKey {
        case mId = "m_id"
        case t1Id = "t1_id"
        case t1Name = "t1_name"
        case t2Id = "t2_id"
        case t2Name = "t2_name"
        case matchStats = "match_stats"
    }
}

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
    
    var matchStats: [MatchStat] = []
    var index = -1
    var m_id:String?
    var l_id:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMatchStats()
    }
    
    func fetchMatchStats() {
        let url = URL(string: matchStatsAPI)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["m_id": m_id!]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch data")
                return
            }
            
            do {
                let matchStatsResponse = try JSONDecoder().decode(MatchStatsResponse.self, from: data)
                
                if let matchStats = matchStatsResponse.result?.matchStats, !matchStats.isEmpty {
                    self.matchStats = matchStats
                    DispatchQueue.main.async {
                        self.teamALbl.text = matchStatsResponse.result?.t1Name
                        self.teamBLbl.text = matchStatsResponse.result?.t2Name
                        self.statusTableView.reloadData()
                    }
                } else {
                    print("Result is empty")
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}

extension StatsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if matchStats.isEmpty == true {
            statusTableView.isHidden = true
            tableHeaderView.isHidden = true
            emptyImg.isHidden = false
        } else {
            statusTableView.isHidden = false
            tableHeaderView.isHidden = false
            emptyImg.isHidden = true
        }
        
        return matchStats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath) as! StatsCell
        cell.selectionStyle = .none
        let stat = matchStats[indexPath.row]
        cell.lblActions?.text = stat.type
        cell.lblTeam1.text = "\(stat.t1Stats)"
        cell.lblTeam2.text = "\(stat.t2Stats)"
        
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
