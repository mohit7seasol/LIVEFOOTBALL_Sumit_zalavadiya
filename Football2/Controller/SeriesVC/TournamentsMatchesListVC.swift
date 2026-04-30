//
//  TournamentsMatchesListVC.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import UIKit
import SVProgressHUD

class TournamentsMatchesListVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nativeAdView: View!
    @IBOutlet weak var tournamentLabel: UILabel!
    
    var googleNativeAds = GoogleNativeAds()
    var tournamentURL: String = ""
    var titleName: String?
    
    var tournamentTemplateId = ""
    var seasonId = ""
    var matches: [TournamentMatch] = []
    var page = 1
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: AnalyticEvent.Series)
        tournamentLabel.text = titleName ?? "Tournaments"
        setupCollectionView()
        fetchTournamentIDs()
        self.showAd()
    }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "TournamentsMatchListCell", bundle: nil), forCellWithReuseIdentifier: "TournamentsMatchListCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    
    func convertTimestamp(_ ts: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(ts))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    
    // MARK: - API Calls
    func fetchTournamentIDs() {
        SVProgressHUD.show()
        
        let encodedURL = tournamentURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/tournaments/ids?tournament_url=\(encodedURL)"
        
        guard let url = URL(string: urlString) else {
            SVProgressHUD.dismiss()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    self?.tournamentTemplateId = json["tournament_template_id"] as? String ?? ""
                    self?.seasonId = json["season_id"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self?.loadMatches()
                    }
                }
            } catch {
                print("Tournament IDs Error:", error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
        }.resume()
    }
    
    func loadMatches() {
        guard !isLoading else { return }
        guard !tournamentTemplateId.isEmpty, !seasonId.isEmpty else { return }
        
        SVProgressHUD.show()
        isLoading = true
        
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/tournaments/results?tournament_template_id=\(tournamentTemplateId)&season_id=\(seasonId)&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            SVProgressHUD.dismiss()
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self?.isLoading = false
                }
                return
            }
            self?.parseMatches(data: data)
        }.resume()
    }
    
    func parseMatches(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                var newMatches: [TournamentMatch] = []
                
                for item in json {
                    let matchId = item["match_id"] as? String ?? ""
                    let timestamp = item["timestamp"] as? Int ?? 0
                    
                    let tournament = item["tournament"] as? [String: Any]
                    let leagueId = tournament?["tournament_template_id"] as? String ?? ""
                    let leagueName = tournament?["name"] as? String ?? ""
                    
                    let homeTeam = item["home_team"] as? [String: Any]
                    let awayTeam = item["away_team"] as? [String: Any]
                    
                    let homeName = homeTeam?["name"] as? String ?? ""
                    let awayName = awayTeam?["name"] as? String ?? ""
                    
                    let homeLogo = homeTeam?["small_image_path"] as? String ?? ""
                    let awayLogo = awayTeam?["small_image_path"] as? String ?? ""
                    
                    let scores = item["scores"] as? [String: Any]
                    
                    let homeScore = scores?["home"] as? Int ?? 0
                    let awayScore = scores?["away"] as? Int ?? 0
                    
                    let match = TournamentMatch(
                        matchId: matchId,
                        timestamp: timestamp,
                        homeName: homeName,
                        awayName: awayName,
                        homeLogo: homeLogo,
                        awayLogo: awayLogo,
                        homeScore: homeScore,
                        awayScore: awayScore,
                        leagueId: leagueId,
                        leagueName: leagueName
                    )
                    
                    newMatches.append(match)
                }
                
                DispatchQueue.main.async {
                    if self.page == 1 {
                        self.matches = newMatches
                    } else {
                        self.matches.append(contentsOf: newMatches)
                    }
                    
                    self.collectionView.reloadData()
                    SVProgressHUD.dismiss()
                    self.isLoading = false
                }
            }
        } catch {
            print("Matches Parse Error:", error)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.isLoading = false
            }
        }
    }
    
    func showAd() {
        self.showSkeleton()
        if isUserSubscribe() == false {
            self.nativeAdView.showAnimatedSkeleton()
            self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                self.nativeAdView.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.hideSkeleton()
                    self.googleNativeAds.showAdsView6(nativeAd: nativeAdsTemp, view: self.nativeAdView)
                }
            }
            self.googleNativeAds.failAds(self) { fail in
                print(" Home...Native fail....")
                self.nativeAdView.isHidden = true
            }
        } else {
            self.hideSkeleton()
            self.nativeAdView.isHidden = true
        }
    }
    
    func showSkeleton() {
        if let adView = Bundle.main.loadNibNamed("SkeletonCustomView3", owner: self, options: nil)?.first as? SkeletonCustomView3 {
            self.nativeAdView.addSubview(adView)
            
            adView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: self.nativeAdView.topAnchor),
                adView.leadingAnchor.constraint(equalTo: self.nativeAdView.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: self.nativeAdView.trailingAnchor),
                adView.bottomAnchor.constraint(equalTo: self.nativeAdView.bottomAnchor)
            ])
            adView.view1.showAnimatedGradientSkeleton()
            adView.view2.showAnimatedGradientSkeleton()
            adView.view3.showAnimatedGradientSkeleton()
            adView.view4.showAnimatedGradientSkeleton()
            adView.view5.showAnimatedGradientSkeleton()
        }
    }
    
    func hideSkeleton() {
        for subview in self.nativeAdView.subviews {
            if let adView = subview as? SkeletonCustomView3 {
                adView.removeFromSuperview()
            }
        }
    }
}

// MARK: - CollectionView Delegate & DataSource
extension TournamentsMatchesListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TournamentsMatchListCell", for: indexPath) as! TournamentsMatchListCell
        
        let match = matches[indexPath.row]
        
        // Set team names
        cell.teamANameLabel.text = match.homeName
        cell.teamBnameLabel.text = match.awayName
        
        // Set score
        cell.scoreLabel.text = "\(match.homeScore)  :  \(match.awayScore)"
        
        // Set date with required format
        cell.dateLabel.text = convertTimestamp(match.timestamp)
        
        // Set flags
        if match.homeLogo.isEmpty {
            cell.teamAflagImageView.image = UIImage(named: "ic_EmptyFlag")
        } else {
            cell.teamAflagImageView.sd_setImage(with: URL(string: match.homeLogo), placeholderImage: UIImage(named: "ic_EmptyFlag"))
        }
        
        if match.awayLogo.isEmpty {
            cell.teamBFlagImageView.image = UIImage(named: "ic_EmptyFlag")
        } else {
            cell.teamBFlagImageView.sd_setImage(with: URL(string: match.awayLogo), placeholderImage: UIImage(named: "ic_EmptyFlag"))
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 30 // 15 left + 15 right
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let height: CGFloat = isPad ? 230 : 130
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Button Actions
extension TournamentsMatchesListVC {
    @IBAction func clickOnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
