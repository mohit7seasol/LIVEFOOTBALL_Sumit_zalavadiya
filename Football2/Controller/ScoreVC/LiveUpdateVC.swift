//
//  LiveUpdateVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

struct Commentary {
    let time: String
    let text: String
    let player1Name: String
    let cardType: String
    let teamName: String
    
    init(time: String, text: String, player1Name: String, cardType: String, teamName: String) {
        self.time = time
        self.text = text
        self.player1Name = player1Name
        self.cardType = cardType
        self.teamName = teamName
    }
    
    init(dictionary: [String: Any]) {
        self.time = dictionary["time"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""
        self.player1Name = dictionary["player1Name"] as? String ?? ""
        self.cardType = dictionary["cardType"] as? String ?? ""
        self.teamName = dictionary["teamName"] as? String ?? ""
    }
}

class LiveUpdateVC: UIViewController {
    
    @IBOutlet weak var liveUpdateTableView: UITableView! {
        didSet {
            self.liveUpdateTableView.register(UINib.init(nibName: "SingleLiveUpdateTblcell", bundle: nil), forCellReuseIdentifier: "SingleLiveUpdateTblcell")
            self.liveUpdateTableView.register(UINib.init(nibName: "DoubleLiveUpdateTblcell", bundle: nil), forCellReuseIdentifier: "DoubleLiveUpdateTblcell")
            self.liveUpdateTableView.register(UINib.init(nibName: "PlayerLiveUpdateCell", bundle: nil), forCellReuseIdentifier: "PlayerLiveUpdateCell")
            liveUpdateTableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var viewForNative: UIView!
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var refreshTimer: Timer?
    var index = -1
    var m_id: String?
    var l_id: String?
    var eventsUpdates: [MatchSummaryEvent] = []
    var commentaryData: [Commentary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !eventsUpdates.isEmpty {
            updateUIWithEvents()
        } else {
            fetchMatchSummary()
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
            self.fetchMatchSummary()
        }
    }
    
    func updateUIWithEvents() {
        commentaryData.removeAll()
        
        for event in eventsUpdates {
            let minutes = event.minutes ?? ""
            let description = event.description ?? ""
            let players = event.players ?? []
            
            let playerName = players.first?.name ?? ""
            let eventType = players.first?.type ?? ""
            
            var cardType = ""
            if eventType.contains("Yellow") {
                cardType = "Yellow card"
            } else if eventType.contains("Red") {
                cardType = "Red card"
            }
            
            let commentary = Commentary(
                time: minutes,
                text: description,
                player1Name: playerName,
                cardType: cardType,
                teamName: event.team ?? ""
            )
            commentaryData.append(commentary)
        }
        
        DispatchQueue.main.async {
            if self.commentaryData.isEmpty {
                self.liveUpdateTableView.isHidden = true
                self.emptyImg.isHidden = false
            } else {
                self.liveUpdateTableView.isHidden = false
                self.emptyImg.isHidden = true
                self.liveUpdateTableView.reloadData()
            }
        }
    }
    
    // MARK: - Reference Code API
    func fetchMatchSummary() {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/match/summary?match_id=\(m_id ?? "")"
        
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
                let result = try JSONDecoder().decode([MatchSummaryEvent].self, from: data)
                
                DispatchQueue.main.async {
                    self?.eventsUpdates = result
                    self?.updateUIWithEvents()
                }
            } catch {
                print("Decode error:", error)
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

extension LiveUpdateVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if commentaryData.isEmpty == true {
            liveUpdateTableView.isHidden = true
            emptyImg.isHidden = false
        } else {
            liveUpdateTableView.isHidden = false
            emptyImg.isHidden = true
        }
        
        return commentaryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let temp = commentaryData[indexPath.row]
        
        if temp.time == "0'" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLiveUpdateTblcell", for: indexPath) as? SingleLiveUpdateTblcell else {
                return UITableViewCell()
            }
            cell.lblText.text = temp.text
            
            DispatchQueue.main.async {
                self.tableHeight.constant = self.liveUpdateTableView.contentSize.height
            }
            
            cell.selectionStyle = .none
            return cell
        } else {
            if temp.player1Name == "" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DoubleLiveUpdateTblcell", for: indexPath) as? DoubleLiveUpdateTblcell else {
                    return UITableViewCell()
                }
                cell.lblTime.text = " \(temp.time) "
                cell.lblText.text = temp.text
                cell.lblCardType.text = temp.cardType
                if temp.cardType.isEmpty {
                    cell.lblCardType.isHidden = true
                } else {
                    cell.lblCardType.isHidden = false
                }
                
                DispatchQueue.main.async {
                    self.tableHeight.constant = self.liveUpdateTableView.contentSize.height
                }
                
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerLiveUpdateCell", for: indexPath) as? PlayerLiveUpdateCell else {
                    return UITableViewCell()
                }
                cell.lblTime.text = " \(temp.time) "
                cell.lblText.text = temp.text
                cell.lblCardType.text = temp.cardType
                cell.lblPlayerName.text = temp.player1Name
                cell.lblGoal.text = temp.teamName
                
                if temp.cardType.isEmpty {
                    cell.lblCardType.isHidden = true
                } else {
                    cell.lblCardType.isHidden = false
                }
                
                DispatchQueue.main.async {
                    self.tableHeight.constant = self.liveUpdateTableView.contentSize.height
                }
                
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let temp = commentaryData[indexPath.row]
        
        if temp.time == "0'" {
            return 44
        } else {
            if temp.player1Name == "" {
                if temp.cardType.isEmpty {
                    return 60
                } else {
                    return 74
                }
            } else {
                if temp.cardType.isEmpty {
                    return 105
                } else {
                    return 120
                }
            }
        }
    }
}
