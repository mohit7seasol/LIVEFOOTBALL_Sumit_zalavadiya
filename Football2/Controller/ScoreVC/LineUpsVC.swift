//
//  LineUpsVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

struct LineupResponse: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let result: MatchResult
}

struct MatchResult: Codable {
    let m_id: String
    let lineup_updates: LineupUpdates
}

struct LineupUpdates: Codable {
    let t1_formation: String
    let t2_formation: String
    let t1_Squad: [Player]
    let t2_Squad: [Player]
}

struct Player: Codable {
    let playerName: String
    let position: String
    let image: String
    let shirtnumber:Int
}

class LineUpsVC: UIViewController {
    
    @IBOutlet weak var lblTeamA: UILabel!
    @IBOutlet weak var imgTeamA: UIImageView!
    @IBOutlet weak var lblScoreA: UILabel!
    
    @IBOutlet weak var lblTeamB: UILabel!
    @IBOutlet weak var imgTeamB: UIImageView!
    @IBOutlet weak var lblScoreB: UILabel!
    
    @IBOutlet weak var viewGoalA1: LinesUpsViewXIB!
    
    @IBOutlet weak var stackViewA: UIStackView!
    @IBOutlet weak var viewDiffA1: LinesUpsViewXIB!
    @IBOutlet weak var viewDiffA2: LinesUpsViewXIB!
    @IBOutlet weak var viewDiffA3: LinesUpsViewXIB!
    @IBOutlet weak var viewDiffA4: LinesUpsViewXIB!
    @IBOutlet weak var viewDiffA5: LinesUpsViewXIB!
    
    @IBOutlet weak var stackViewAA: UIStackView!
    @IBOutlet weak var viewMidDiffA1: LinesUpsViewXIB!
    @IBOutlet weak var viewMidDiffA2: LinesUpsViewXIB!
    @IBOutlet weak var viewMidDiffA3: LinesUpsViewXIB!
    @IBOutlet weak var viewMidDiffA4: LinesUpsViewXIB!
    @IBOutlet weak var viewMidDiffA5: LinesUpsViewXIB!
    
    @IBOutlet weak var viewGoalB1: LinesUpsViewXIB!
    
    @IBOutlet weak var stackViewB: UIStackView!
    @IBOutlet weak var viewDiffB1: LinesUpsViewXIB!
    @IBOutlet weak var viewDiffB2: LinesUpsViewXIB!
    @IBOutlet weak var viewDiffB3: LinesUpsViewXIB!
    @IBOutlet weak var viewDiffB4: LinesUpsViewXIB!
    @IBOutlet weak var viewDiffB5: LinesUpsViewXIB!
    
    @IBOutlet weak var stackViewBB: UIStackView!
    @IBOutlet weak var viewMidDiffB1: LinesUpsViewXIB!
    @IBOutlet weak var viewMidDiffB2: LinesUpsViewXIB!
    @IBOutlet weak var viewMidDiffB3: LinesUpsViewXIB!
    @IBOutlet weak var viewMidDiffB4: LinesUpsViewXIB!
    @IBOutlet weak var viewMidDiffB5: LinesUpsViewXIB!
    
    @IBOutlet weak var viewForNative: UIView!
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var index = -1
    var m_id:String?
    var l_id:String?
    var Aname:String?
    var Bname:String?
    var Aimg:String?
    var Bimg:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.Aname?.isEmpty == false {
            self.lblTeamA.text = self.Aname
        } else {
            self.lblTeamA.text = "TeamA"
        }
        
        if self.Bname?.isEmpty == false {
            self.lblTeamB.text = self.Bname
        } else {
            self.lblTeamB.text = "TeamB"
        }
        
        if self.Aimg?.isEmpty == false {
            let urlA = URL(string: self.Aimg!)
            self.imgTeamA.sd_setImage(with: urlA, placeholderImage: UIImage(named: "DefaultFlag"))
        } else {
            self.imgTeamA.image = UIImage(named: "DefaultFlag")!
        }
        
        if self.Bimg?.isEmpty == false {
            let urlA = URL(string: self.Bimg!)
            self.imgTeamB.sd_setImage(with: urlA, placeholderImage: UIImage(named: "DefaultFlag"))
        } else {
            self.imgTeamB.image = UIImage(named: "DefaultFlag")!
        }
        
        fetchLineupData()
    }
    
    func setData(view: LinesUpsViewXIB, lbltitle:String, count:String) {
        view.lblNAme.text = lbltitle
        view.lblShirtNum.text = count
    }
    
    func fetchLineupData() {
        let url = URL(string: matchLineUps)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["m_id": m_id!]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(String(describing: error))")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(LineupResponse.self, from: data)
                DispatchQueue.main.async {
                    self.lblScoreA.text = response.result.lineup_updates.t1_formation
                    self.lblScoreB.text = response.result.lineup_updates.t2_formation
                    
                    if response.result.lineup_updates.t1_Squad.isEmpty == false {
                        self.viewGoalA1.isHidden = false
                        self.stackViewA.isHidden = false
                        self.stackViewAA.isHidden = false
                        self.updateUI1(with: response.result.lineup_updates.t1_Squad)
                    } else {
                        self.viewGoalA1.isHidden = true
                        self.stackViewA.isHidden = true
                        self.stackViewAA.isHidden = true
                    }
                    
                    if response.result.lineup_updates.t2_Squad.isEmpty == false {
                        self.viewGoalB1.isHidden = false
                        self.stackViewB.isHidden = false
                        self.stackViewBB.isHidden = false
                        self.updateUI2(with: response.result.lineup_updates.t2_Squad)
                    } else {
                        self.viewGoalB1.isHidden = true
                        self.stackViewB.isHidden = true
                        self.stackViewBB.isHidden = true
                    }
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }.resume()
    }
    
    func updateUI1(with players: [Player]) {
        guard players.count >= 11 else { return }
        
        if let goalkeeper = players.first(where: { $0.position == "Goalkeeper" }) {
            setData(view: viewGoalA1, lbltitle: goalkeeper.playerName, count: "\(goalkeeper.shirtnumber)")
        }
        
        // Filter out the Goalkeeper and set the rest of the players in different labels
        let otherPlayers = players.filter { $0.position != "Goalkeeper" }
        
        // Ensure there are enough players for all labels
        guard otherPlayers.count >= 10 else { return }
        
        // Set the remaining players' data in different labels
        setData(view: viewDiffA1, lbltitle: otherPlayers[0].playerName, count: "\(otherPlayers[0].shirtnumber)")
        setData(view: viewDiffA2, lbltitle: otherPlayers[1].playerName, count: "\(otherPlayers[1].shirtnumber)")
        setData(view: viewDiffA3, lbltitle: otherPlayers[2].playerName, count: "\(otherPlayers[2].shirtnumber)")
        setData(view: viewDiffA4, lbltitle: otherPlayers[3].playerName, count: "\(otherPlayers[3].shirtnumber)")
        setData(view: viewDiffA5, lbltitle: otherPlayers[4].playerName, count: "\(otherPlayers[4].shirtnumber)")
        
        setData(view: viewMidDiffA1, lbltitle: otherPlayers[5].playerName, count: "\(otherPlayers[5].shirtnumber)")
        setData(view: viewMidDiffA2, lbltitle: otherPlayers[6].playerName, count: "\(otherPlayers[6].shirtnumber)")
        setData(view: viewMidDiffA3, lbltitle: otherPlayers[7].playerName, count: "\(otherPlayers[7].shirtnumber)")
        setData(view: viewMidDiffA4, lbltitle:  otherPlayers[8].playerName, count: "\(otherPlayers[8].shirtnumber)")
        setData(view: viewMidDiffA5, lbltitle:  otherPlayers[9].playerName, count: "\(otherPlayers[9].shirtnumber)")
    }
    
    func updateUI2(with players: [Player]) {
        guard players.count >= 11 else { return }
        
        if let goalkeeper = players.first(where: { $0.position == "Goalkeeper" }) {
            setData(view: viewGoalB1, lbltitle: goalkeeper.playerName, count: "\(goalkeeper.shirtnumber)")
        }
        
        // Filter out the Goalkeeper and set the rest of the players in different labels
        let otherPlayers = players.filter { $0.position != "Goalkeeper" }
        
        // Ensure there are enough players for all labels
        guard otherPlayers.count >= 10 else { return }
        
        // Set the remaining players' data in different labels
        setData(view: viewDiffB1, lbltitle: otherPlayers[0].playerName, count: "\(otherPlayers[0].shirtnumber)")
        setData(view: viewDiffB2, lbltitle: otherPlayers[1].playerName, count: "\(otherPlayers[1].shirtnumber)")
        setData(view: viewDiffB3, lbltitle: otherPlayers[2].playerName, count: "\(otherPlayers[2].shirtnumber)")
        setData(view: viewDiffB4, lbltitle: otherPlayers[3].playerName, count: "\(otherPlayers[3].shirtnumber)")
        setData(view: viewDiffB5, lbltitle: otherPlayers[4].playerName, count: "\(otherPlayers[4].shirtnumber)")
        
        setData(view: viewMidDiffB1, lbltitle: otherPlayers[5].playerName, count: "\(otherPlayers[5].shirtnumber)")
        setData(view: viewMidDiffB2, lbltitle: otherPlayers[6].playerName, count: "\(otherPlayers[6].shirtnumber)")
        setData(view: viewMidDiffB3, lbltitle: otherPlayers[7].playerName, count: "\(otherPlayers[7].shirtnumber)")
        setData(view: viewMidDiffB4, lbltitle:  otherPlayers[8].playerName, count: "\(otherPlayers[8].shirtnumber)")
        setData(view: viewMidDiffB5, lbltitle:  otherPlayers[9].playerName, count: "\(otherPlayers[9].shirtnumber)")
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
