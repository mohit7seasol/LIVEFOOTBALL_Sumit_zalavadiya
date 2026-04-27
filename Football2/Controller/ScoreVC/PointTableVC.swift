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
    var teams: [Team] = []
    var l_id:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableHeaderView.layer.cornerRadius = 20
        self.tableHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTeamStandings()
    }
    
    func fetchTeamStandings() {
        guard let url = URL(string: matchPointTbl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "spt_typ": 2,
            "l_id": l_id!,
            "is_latest": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(TeamStandingsResponse.self, from: data)
                guard response.status, let result = response.result, let standings = result.team_standings, !standings.isEmpty else {
                    print("No data available")
                    return
                }
                
                self.teams = standings.flatMap { $0.standings }
                
                DispatchQueue.main.async {
                    self.pointsTableView.reloadData()
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        
        task.resume()
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
    
}

extension PointTableVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if teams.isEmpty == true {
            emptyImg.isHidden = false
            tableCustomView.isHidden = true
        } else {
            emptyImg.isHidden = true
            tableCustomView.isHidden = false
        }
        
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
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.pointsTableView.contentSize.height
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
}
