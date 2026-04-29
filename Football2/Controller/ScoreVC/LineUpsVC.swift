//
//  LineUpsVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit
import MarqueeLabel

class LineUpsVC: UIViewController {
    
    @IBOutlet weak var lblTeamA: MarqueeLabel!
    @IBOutlet weak var imgTeamA: UIImageView!
    @IBOutlet weak var lblScoreA: UILabel!
    
    @IBOutlet weak var lblTeamB: MarqueeLabel!
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
    var matchDetails: MatchDetails?
    var lineupData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTeamInfo()
        
        if !lineupData.isEmpty {
            processLineupData()
        } else {
            fetchLineupData()
        }
    }
    
    func setupTeamInfo() {
        if let details = matchDetails {
            lblTeamA.text = details.homeName
            lblTeamB.text = details.awayName
            if let url = URL(string: details.homeLogo), !details.homeLogo.isEmpty {
                imgTeamA.sd_setImage(with: url, placeholderImage: UIImage(named: "DefaultFlag"))
            }
            if let url = URL(string: details.awayLogo), !details.awayLogo.isEmpty {
                imgTeamB.sd_setImage(with: url, placeholderImage: UIImage(named: "DefaultFlag"))
            }
        } else {
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
        }
    }
    
    func setData(view: LinesUpsViewXIB, lbltitle: String, count: String) {
        view.lblNAme.text = lbltitle
        view.lblShirtNum.text = count
    }
    
    // MARK: - Updated API from Reference Code
    func fetchLineupData() {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/match/lineups?match_id=\(m_id ?? "")"
        
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
                let result = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
                guard let teams = result, teams.count >= 2 else { return }
                
                DispatchQueue.main.async {
                    self?.lineupData = teams
                    self?.processLineupData()
                }
            } catch {
                print("JSON Error:", error)
            }
        }.resume()
    }
    
    func processLineupData() {
        guard lineupData.count >= 2 else { return }
        
        let homeTeam = lineupData[0]
        let awayTeam = lineupData[1]
        
        let homeFormation = homeTeam["predictedFormation"] as? String
        let awayFormation = awayTeam["predictedFormation"] as? String
        
        lblScoreA.text = homeFormation
        lblScoreB.text = awayFormation
        
        var homePlayers = homeTeam["startingLineups"] as? [[String: Any]] ?? []
        if homePlayers.isEmpty {
            homePlayers = homeTeam["predictedLineups"] as? [[String: Any]] ?? []
        }
        
        var awayPlayers = awayTeam["startingLineups"] as? [[String: Any]] ?? []
        if awayPlayers.isEmpty {
            awayPlayers = awayTeam["predictedLineups"] as? [[String: Any]] ?? []
        }
        
        if !homePlayers.isEmpty {
            updateHomePlayers(homePlayers)
        } else {
            viewGoalA1.isHidden = true
            stackViewA.isHidden = true
            stackViewAA.isHidden = true
        }
        
        if !awayPlayers.isEmpty {
            updateAwayPlayers(awayPlayers)
        } else {
            viewGoalB1.isHidden = true
            stackViewB.isHidden = true
            stackViewBB.isHidden = true
        }
    }
    
    func updateHomePlayers(_ players: [[String: Any]]) {
        guard players.count >= 11 else {
            viewGoalA1.isHidden = true
            stackViewA.isHidden = true
            stackViewAA.isHidden = true
            return
        }
        
        let goalkeeper = players[0]
        setData(view: viewGoalA1, lbltitle: goalkeeper["fieldName"] as? String ?? "", count: goalkeeper["number"] as? String ?? "")
        
        let others = Array(players.dropFirst())
        
        setData(view: viewDiffA1, lbltitle: others[0]["fieldName"] as? String ?? "", count: others[0]["number"] as? String ?? "")
        setData(view: viewDiffA2, lbltitle: others[1]["fieldName"] as? String ?? "", count: others[1]["number"] as? String ?? "")
        setData(view: viewDiffA3, lbltitle: others[2]["fieldName"] as? String ?? "", count: others[2]["number"] as? String ?? "")
        setData(view: viewDiffA4, lbltitle: others[3]["fieldName"] as? String ?? "", count: others[3]["number"] as? String ?? "")
        setData(view: viewDiffA5, lbltitle: others[4]["fieldName"] as? String ?? "", count: others[4]["number"] as? String ?? "")
        
        setData(view: viewMidDiffA1, lbltitle: others[5]["fieldName"] as? String ?? "", count: others[5]["number"] as? String ?? "")
        setData(view: viewMidDiffA2, lbltitle: others[6]["fieldName"] as? String ?? "", count: others[6]["number"] as? String ?? "")
        setData(view: viewMidDiffA3, lbltitle: others[7]["fieldName"] as? String ?? "", count: others[7]["number"] as? String ?? "")
        setData(view: viewMidDiffA4, lbltitle: others[8]["fieldName"] as? String ?? "", count: others[8]["number"] as? String ?? "")
        setData(view: viewMidDiffA5, lbltitle: others[9]["fieldName"] as? String ?? "", count: others[9]["number"] as? String ?? "")
        
        viewGoalA1.isHidden = false
        stackViewA.isHidden = false
        stackViewAA.isHidden = false
    }
    
    func updateAwayPlayers(_ players: [[String: Any]]) {
        guard players.count >= 11 else {
            viewGoalB1.isHidden = true
            stackViewB.isHidden = true
            stackViewBB.isHidden = true
            return
        }
        
        let goalkeeper = players[0]
        setData(view: viewGoalB1, lbltitle: goalkeeper["fieldName"] as? String ?? "", count: goalkeeper["number"] as? String ?? "")
        
        let others = Array(players.dropFirst())
        
        setData(view: viewDiffB1, lbltitle: others[0]["fieldName"] as? String ?? "", count: others[0]["number"] as? String ?? "")
        setData(view: viewDiffB2, lbltitle: others[1]["fieldName"] as? String ?? "", count: others[1]["number"] as? String ?? "")
        setData(view: viewDiffB3, lbltitle: others[2]["fieldName"] as? String ?? "", count: others[2]["number"] as? String ?? "")
        setData(view: viewDiffB4, lbltitle: others[3]["fieldName"] as? String ?? "", count: others[3]["number"] as? String ?? "")
        setData(view: viewDiffB5, lbltitle: others[4]["fieldName"] as? String ?? "", count: others[4]["number"] as? String ?? "")
        
        setData(view: viewMidDiffB1, lbltitle: others[5]["fieldName"] as? String ?? "", count: others[5]["number"] as? String ?? "")
        setData(view: viewMidDiffB2, lbltitle: others[6]["fieldName"] as? String ?? "", count: others[6]["number"] as? String ?? "")
        setData(view: viewMidDiffB3, lbltitle: others[7]["fieldName"] as? String ?? "", count: others[7]["number"] as? String ?? "")
        setData(view: viewMidDiffB4, lbltitle: others[8]["fieldName"] as? String ?? "", count: others[8]["number"] as? String ?? "")
        setData(view: viewMidDiffB5, lbltitle: others[9]["fieldName"] as? String ?? "", count: others[9]["number"] as? String ?? "")
        
        viewGoalB1.isHidden = false
        stackViewB.isHidden = false
        stackViewBB.isHidden = false
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
