//
//  LiveUpdateVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

struct Commentary {
    let min: Int
    let time: String
    let text: String
    let player1Name: String
    let cardType: String
    let teamName: String
    
    init(dictionary: [String: Any]) {
        self.min = dictionary["min"] as? Int ?? 0
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
    var m_id:String?
    var l_id:String?
    var commentaryData: [Commentary] = []
    
    var existingTexts: Set<String> = []
    var hasInitialLoadCompleted = false
    var currentMin: Int = 0
    var isFetching = false
    var isMatchLive = false
    
    var seenTexts: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadInitialData()
        // Start live refresh if match is live
        if self.isMatchLive {
            DispatchQueue.main.async {
                self.startAutoRefresh()
            }
        }
    }
    
    func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
           self?.fetchNewCommentary()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func loadInitialData() {
        guard let matchId = m_id else { return }

        let requestMin = hasInitialLoadCompleted ? (currentMin - 1) : 0
        if requestMin < 0 { return }

        let url = URL(string: matchLiveUpdate)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = ["m_id": matchId, "min": requestMin, "refid": 0]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let result = json?["result"] as? [String: Any],
                   let dataArray = result["data"] as? [[String: Any]] {

                    var newCommentary = dataArray.map { Commentary(dictionary: $0) }

                    // First load: handle initial 2 items
                    if !self.hasInitialLoadCompleted {
                        self.hasInitialLoadCompleted = true
                        if newCommentary.count > 2 {
                            let firstTwo = Array(newCommentary.prefix(2))
                            self.commentaryData.append(contentsOf: firstTwo)
                            newCommentary = Array(newCommentary.dropFirst(2))
                        }
                    }

                    // Get existing text for time == "0'"
                    let existingZeroTimeTexts = Set(self.commentaryData.filter { $0.time == "0'" }.map { $0.text })

                    // Filter only if time == "0'" and text is already added
                    let filteredCommentary = newCommentary.filter {
                        !($0.time == "0'" && existingZeroTimeTexts.contains($0.text))
                    }

                    // Append filtered data
                    self.commentaryData.append(contentsOf: filteredCommentary)

                    // Update min if available
                    if let last = filteredCommentary.last {
                        self.currentMin = last.min
                    }

                    DispatchQueue.main.async {
                        self.liveUpdateTableView.reloadData()
                    }

                    // Continue fetching until min is 0
                    if self.currentMin > 0 {
                        self.loadInitialData()
                    }
                    
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func fetchNewCommentary() {
        guard let matchId = m_id else { return }
        guard let url = URL(string: matchLiveUpdate) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = ["m_id": matchId, "min": 0, "refid": 0]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let dataArray = result["data"] as? [[String: Any]] {

                    let incomingCommentary = dataArray.map { Commentary(dictionary: $0) }

                    // Create a set of identifiers for existing items to avoid duplication
                    let existingIdentifiers = Set(self.commentaryData.map { "\($0.min)-\($0.text)" })

                    // Filter out any items that already exist
                    let newItems = incomingCommentary.filter {
                        !existingIdentifiers.contains("\($0.min)-\($0.text)")
                    }

                    if !newItems.isEmpty {
                        // ✅ Insert new items directly (no reversal)
                        self.commentaryData.insert(contentsOf: newItems, at: 0)

                        if let last = newItems.last {
                            self.currentMin = last.min
                        }

                        DispatchQueue.main.async {
                            self.liveUpdateTableView.reloadData()
                            self.liveUpdateTableView.setContentOffset(.zero, animated: true)
                        }
                    }
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
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
        
        let commentary = commentaryData[indexPath.row]
        
        if commentary.time == "0'" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLiveUpdateTblcell", for: indexPath) as? SingleLiveUpdateTblcell else {
                return UITableViewCell()
            }
            cell.lblText.text = commentary.text
            
            DispatchQueue.main.async {
                self.tableHeight.constant = self.liveUpdateTableView.contentSize.height
            }
            
            cell.selectionStyle = .none
            return cell
        } else {
            if commentary.player1Name == "" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DoubleLiveUpdateTblcell", for: indexPath) as? DoubleLiveUpdateTblcell else {
                    return UITableViewCell()
                }
                cell.lblTime.text = " \(commentary.time) "
                cell.lblText.text = commentary.text
                cell.lblCardType.text = commentary.cardType
                if commentary.cardType.isEmpty {
                    cell.lblCardType.isHidden = true
                }else {
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
                cell.lblTime.text = " \(commentary.time) "
                cell.lblText.text = commentary.text
                cell.lblCardType.text = commentary.cardType
                cell.lblPlayerName.text = commentary.player1Name
                cell.lblGoal.text = commentary.teamName
                
                if commentary.cardType.isEmpty {
                    cell.lblCardType.isHidden = true
                }else {
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
        
        let commentary = commentaryData[indexPath.row]
        
        if commentary.time == "0'" {
            return 44
        } else {
            if commentary.player1Name == "" {
                if commentary.cardType.isEmpty {
                    return 60
                } else {
                    return 74
                }
            } else {
                if commentary.cardType.isEmpty {
                    return 105
                } else {
                    return 120
                }
            }
        }
        
    }
    
}
