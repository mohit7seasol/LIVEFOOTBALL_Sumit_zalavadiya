//
//  HeadToHeadDetailsVC.swift
//  Football
//
//  Created by Mohit Kanpara on 11/04/26.
//

import UIKit
import SDWebImage

class HeadToHeadDetailsVC: UIViewController {
    
    @IBOutlet weak var tblSquadList: UITableView!{
        didSet{
            tblSquadList.register(UINib(nibName: "HeadToHeadCell", bundle: nil), forCellReuseIdentifier: "HeadToHeadCell")
        }
    }
    
    @IBOutlet weak var team1Lbl: UILabel!
    @IBOutlet weak var team2Lbl: UILabel!
    
    var index = -1
    var m_id:String?
    var l_id:String?
    var Aname:String?
    var Bname:String?
    var matchDetails: MatchDetails?
    var standings: [Standing] = []
    // H2H Data from API
    var h2hMatches: [H2HMatch] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchHead2HeadMatches()
    }
    
    func setupUI() {
        // Use matchDetails if available for team names
        if let details = matchDetails {
            team1Lbl.text = details.homeName
            team2Lbl.text = details.awayName
        } else {
            if self.Aname?.isEmpty == false {
                self.team1Lbl.text = self.Aname
            } else {
                self.team1Lbl.text = "TeamA"
            }
            
            if self.Bname?.isEmpty == false {
                self.team2Lbl.text = self.Bname
            } else {
                self.team2Lbl.text = "TeamB"
            }
        }
    }
    
    // MARK: - Head2Head API Call (Reference Code)
    func fetchHead2HeadMatches() {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/h2h?match_id=\(m_id ?? "")"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(APITOKEN, forHTTPHeaderField: "x-rapidapi-key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data, error == nil else {
                print("API Error:", error?.localizedDescription ?? "")
                return
            }
            
            do {
                // Direct array decode
                let allMatches = try JSONDecoder().decode([H2HMatch].self, from: data)
                
                // Filter matches involving both teams
                let team1Name = self?.matchDetails?.homeName ?? self?.Aname ?? ""
                let team2Name = self?.matchDetails?.awayName ?? self?.Bname ?? ""
                
                let filtered = allMatches.filter {
                    let home = $0.home_team?.name?.lowercased() ?? ""
                    let away = $0.away_team?.name?.lowercased() ?? ""
                    
                    let team1 = team1Name.lowercased()
                    let team2 = team2Name.lowercased()
                    
                    return (home.contains(team1) && away.contains(team2)) ||
                           (home.contains(team2) && away.contains(team1))
                }
                
                // Sort (latest first)
                let sorted = filtered.sorted {
                    ($0.timestamp ?? 0) > ($1.timestamp ?? 0)
                }
                
                DispatchQueue.main.async {
                    self?.h2hMatches = sorted
                    self?.tblSquadList.reloadData()
                }
                
            } catch {
                print("Decode error:", error)
            }
        }.resume()
    }
    
    // Helper function to convert timestamp to date string
//    func convertTimestamp(_ ts: Int?) -> String {
//        guard let ts = ts else { return "" }
//        let date = Date(timeIntervalSince1970: TimeInterval(ts))
//        let df = DateFormatter()
//        df.dateFormat = "dd MMM yyyy"
//        return df.string(from: date)
//    }
    func convertTimestamp(_ ts: Int?) -> (date: String, time: String) {
        
        guard let ts = ts else { return ("", "") }
        
        let date = Date(timeIntervalSince1970: TimeInterval(ts))
        
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        
        let tf = DateFormatter()
        tf.dateFormat = "hh:mm a"
        
        return (df.string(from: date), tf.string(from: date))
    }
    
}

extension HeadToHeadDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return h2hMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblSquadList.dequeueReusableCell(withIdentifier: "HeadToHeadCell", for: indexPath) as! HeadToHeadCell
        
        let match = h2hMatches[indexPath.row]
        
        let homeTeam = match.home_team
        let awayTeam = match.away_team
        
        cell.selectionStyle = .none
        
        // Set team names
        cell.lblTeam1Name.text = homeTeam?.name ?? ""
        cell.lblTeam2lblName.text = awayTeam?.name ?? ""
        
        // Set scores
        let homeScore = match.scores?.home ?? ""
        let awayScore = match.scores?.away ?? ""
        
        if homeScore.isEmpty && awayScore.isEmpty {
            cell.lblTeam1homeScore.text = "vs"
            cell.lblTeam2awayScore.text = ""
        } else {
            cell.lblTeam1homeScore.text = homeScore
            cell.lblTeam2awayScore.text = awayScore
        }
        
        // Set team flags
        if let img = homeTeam?.image_path, !img.isEmpty, let url = URL(string: img) {
            cell.imgTeam1Flag.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_EmptyFlag"))
        } else {
            cell.imgTeam1Flag.image = UIImage(named: "ic_EmptyFlag")
        }
        
        if let img = awayTeam?.image_path, !img.isEmpty, let url = URL(string: img) {
            cell.imgTeam2Flag.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_EmptyFlag"))
        } else {
            cell.imgTeam2Flag.image = UIImage(named: "ic_EmptyFlag")
        }
        
        // date
        let result = convertTimestamp(match.timestamp)
        cell.lblTeam1Date.text = "\(result.date) \n \(result.time)"
        cell.lblTeam2Date.text = "\(result.date) \n \(result.time)"
//        cell.lblTeam1Date.isHidden = true
//        cell.lblTeam2Date.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
