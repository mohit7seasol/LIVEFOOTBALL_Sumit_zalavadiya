//
//  PointTableVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit
struct Team: Codable {
    let tname: String
    let P: Int
    let W: Int
    let L: Int
    let D: Int
    let PTS: Int
}

struct Standings: Codable {
    let standings: [Team]
}

struct TeamStandingsResponse: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let result: ResultData?
    
    struct ResultData: Codable {
        let team_standings: [Standings]?
    }
}
class PointTableVC: UIViewController {
    
    @IBOutlet weak var tableCustomView: CustomView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var pointsTableView: UITableView! {
        didSet {
            self.pointsTableView.register(UINib.init(nibName: "PointTableCell", bundle: nil), forCellReuseIdentifier: "PointTableCell")
            self.pointsTableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var viewForNative: UIView!
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var index = -1
    var m_id: String?
    var l_id: String?
    var standings: [Standing] = []
    var teams: [Team] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableHeaderView.layer.cornerRadius = 20
        self.tableHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !standings.isEmpty {
            updateUIWithStandings()
        } else {
            fetchMatchStandings()
        }
    }
    
    func updateUIWithStandings() {
        teams = standings.map { standing in
            Team(
                tname: standing.name ?? "",
                P: standing.matches_played ?? 0,
                W: standing.wins ?? 0,
                L: standing.losses ?? 0,
                D: standing.draws ?? 0,
                PTS: standing.points ?? 0
            )
        }
        teams.sort { $0.PTS > $1.PTS }
        
        DispatchQueue.main.async {
            if self.teams.isEmpty {
                self.emptyImg.isHidden = false
                self.tableCustomView.isHidden = true
                self.pointsTableView.isHidden = true
            } else {
                self.emptyImg.isHidden = true
                self.tableCustomView.isHidden = false
                self.pointsTableView.isHidden = false
                self.pointsTableView.reloadData()
            }
        }
    }
    
    // MARK: - Fixed API Call with proper error handling
    func fetchMatchStandings() {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/standings?type=overall&match_id=\(m_id ?? "")"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(APITOKEN, forHTTPHeaderField: "x-rapidapi-key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("API Error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            // Debug: Print raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Standings API Response: \(jsonString)")
            }
            
            do {
                // Try to decode as array of Standing objects
                let decoder = JSONDecoder()
                let result = try decoder.decode([Standing].self, from: data)
                
                print("Successfully decoded \(result.count) standings")
                
                DispatchQueue.main.async {
                    self?.standings = result
                    self?.updateUIWithStandings()
                }
            } catch {
                print("Decode error:", error)
                
                // If array decode fails, try to decode as dictionary with standings array
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("Response keys: \(json.keys)")
                        
                        // Check different possible response structures
                        if let standingsArray = json["standings"] as? [[String: Any]] {
                            print("Found standings array with \(standingsArray.count) items")
                            // Manually parse if needed
                        } else if let result = json["result"] as? [String: Any],
                                  let teamStandings = result["team_standings"] as? [[String: Any]] {
                            print("Found team_standings with \(teamStandings.count) items")
                        }
                    }
                } catch {
                    print("JSON serialization error:", error)
                }
            }
        }.resume()
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
}

extension PointTableVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointTableCell", for: indexPath) as! PointTableCell
        cell.selectionStyle = .none
        
        let team = teams[indexPath.row]
        
        cell.lblTeamName.text = team.tname
        cell.lblM.text = "\(team.P)"
        cell.lblW.text = "\(team.W)"
        cell.lblL.text = "\(team.L)"
        cell.lblD.text = "\(team.D)"
        cell.lblPTS.text = "\(team.PTS)"
        
        // Optional: Add corner radius for last cell
        if indexPath.row == teams.count - 1 {
            cell.customView.layer.cornerRadius = 8
            cell.customView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.pointsTableView.contentSize.height
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
