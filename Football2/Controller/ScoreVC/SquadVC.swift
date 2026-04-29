//
//  SquadVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import Foundation

struct Squad: Codable {
    var imageURL: String
    let role: String
    let name: String
}

struct SquadResponse: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let result: ResultData?
}

struct ResultData: Codable {
    let t1_squad: [Squad]
    let t2_squad: [Squad]
}



class SquadVC: UIViewController {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var team1Lbl: UILabel!
    @IBOutlet weak var team2Lbl: UILabel!
    @IBOutlet weak var squadTableView: UITableView! {
        didSet {
            self.squadTableView.register(UINib.init(nibName: "SquadCell", bundle: nil), forCellReuseIdentifier: "SquadCell")
            squadTableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var viewForNative: UIView!
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var index = -1
    var squad1: [Squad] = []
    var squad2: [Squad] = []
    var m_id:String?
    var l_id:String?
    var Aname:String?
    var Bname:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchSquads()
        setupUI()
    }
    
    func setupUI() {
        
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
    
    func fetchSquads() {
        let url = URL(string: matchSquad)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = ["spt_typ": 2, "l_id": l_id!, "m_id": m_id!] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = jsonResponse as? [String: Any],
                   let result = dictionary["result"] as? [String: Any] {
                    if let t1Squad = result["t1_squad"] as? [[String: Any]] {
                        self.squad1 = t1Squad.compactMap { playerDict in
                            if let name = playerDict["name"] as? String,
                               let role = playerDict["role"] as? String,
                               let imageURL = playerDict["image"] as? String {
                                return Squad(imageURL: imageURL, role: role, name: name)
                            }
                            return nil
                        }
                    }
                    if let t2Squad = result["t2_squad"] as? [[String: Any]] {
                        self.squad2 = t2Squad.compactMap { playerDict in
                            if let name = playerDict["name"] as? String,
                               let role = playerDict["role"] as? String,
                               let imageURL = playerDict["image"] as? String {
                                return Squad(imageURL: imageURL, role: role, name: name)
                            }
                            return nil
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.squadTableView.reloadData()
                }
            } catch {
                print("Failed to parse JSON")
            }
        }.resume()
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
    
}

extension SquadVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = max(squad1.count, squad2.count)
        
        if count == 0 {
            squadTableView.isHidden = true
            tableHeaderView.isHidden = true
            emptyImg.isHidden = false
        } else {
            squadTableView.isHidden = false
            tableHeaderView.isHidden = false
            emptyImg.isHidden = true
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SquadCell", for: indexPath) as! SquadCell
        cell.selectionStyle = .none
        
        // Team 1 player
        if indexPath.row < squad1.count {
            let player1 = squad1[indexPath.row]
            cell.team1PlayerNameLbl.text = player1.name
            cell.team1PlayerRoleLbl.text = player1.role
            cell.team1PlayerImg.isHidden = false
        } else {
            cell.team1PlayerNameLbl.text = ""
            cell.team1PlayerRoleLbl.text = ""
            cell.team1PlayerImg.isHidden = true
        }
        
        // Team 2 player
        if indexPath.row < squad2.count {
            let player2 = squad2[indexPath.row]
            cell.team2PlayerNameLbl.text = player2.name
            cell.team2PlayerRoleLbl.text = player2.role
            cell.team2PlayerImg.isHidden = false
        } else {
            cell.team2PlayerNameLbl.text = ""
            cell.team2PlayerRoleLbl.text = ""
            cell.team2PlayerImg.isHidden = true
        }
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.squadTableView.contentSize.height
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
