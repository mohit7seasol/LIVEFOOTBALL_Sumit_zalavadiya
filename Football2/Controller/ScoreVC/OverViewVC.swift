//
//  OverViewVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

// Converted Event Model for UI
struct ConvertedEvent {
    let time: String
    let t_id: Int
    let playerInName: String
    let playerOutName: String
    let text: String
    let card: String
    let eventType: String
}

class OverViewVC: UIViewController {
    
    @IBOutlet weak var overViewTableView: UITableView! {
        didSet {
            self.overViewTableView.register(UINib.init(nibName: "TeamA1Cell", bundle: nil), forCellReuseIdentifier: "TeamA1Cell")
            self.overViewTableView.register(UINib.init(nibName: "TeamA2Cell", bundle: nil), forCellReuseIdentifier: "TeamA2Cell")
            self.overViewTableView.register(UINib.init(nibName: "TeamA3Cell", bundle: nil), forCellReuseIdentifier: "TeamA3Cell")
            self.overViewTableView.register(UINib.init(nibName: "TeamB1Cell", bundle: nil), forCellReuseIdentifier: "TeamB1Cell")
            self.overViewTableView.register(UINib.init(nibName: "TeamB2Cell", bundle: nil), forCellReuseIdentifier: "TeamB2Cell")
            self.overViewTableView.register(UINib.init(nibName: "TeamB3Cell", bundle: nil), forCellReuseIdentifier: "TeamB3Cell")
            self.overViewTableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var emptyImg: UIImageView!
    
    var index = -1
    var m_id:String?
    var l_id:String?
    var eventsUpdates: [MatchSummaryEvent] = []
    var convertedEvents: [ConvertedEvent] = []
    var t_1ID: Int = 1
    var t_2ID: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !eventsUpdates.isEmpty {
            convertEventsToUIModel()
            overViewTableView.reloadData()
        } else {
            fetchMatchSummary()
        }
    }
    
    // MARK: - Updated API from Reference Code
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
                    self?.convertEventsToUIModel()
                    self?.overViewTableView.reloadData()
                    
                    if self?.convertedEvents.isEmpty == true {
                        self?.overViewTableView.isHidden = true
                        self?.emptyImg.isHidden = false
                    } else {
                        self?.overViewTableView.isHidden = false
                        self?.emptyImg.isHidden = true
                    }
                }
            } catch {
                print("Decode error:", error)
            }
        }.resume()
    }
    
    func convertEventsToUIModel() {
        convertedEvents.removeAll()
        
        for event in eventsUpdates {
            let isHome = event.team?.lowercased() == "home"
            let teamId = isHome ? t_1ID : t_2ID
            
            let minute = event.minutes ?? ""
            let players = event.players ?? []
            
            let subIn = players.first(where: { $0.type?.contains("In") == true })
            let subOut = players.first(where: { $0.type?.contains("Out") == true })
            let eventType = players.first?.type ?? ""
            
            let fallbackPlayer = players.first?.name ?? ""
            let fallbackType = players.first?.type ?? ""
            let text = (event.description?.isEmpty == false) ? event.description! : (!fallbackPlayer.isEmpty ? fallbackPlayer : fallbackType)
            
            var cardType = ""
            if eventType.contains("Yellow") {
                cardType = "Yellow card"
            } else if eventType.contains("Red") {
                cardType = "Red card"
            } else if eventType.contains("Goal") || eventType.contains("Penalty") {
                cardType = "Goal"
            }
            
            let convertedEvent = ConvertedEvent(
                time: minute,
                t_id: teamId,
                playerInName: subIn?.name ?? "",
                playerOutName: subOut?.name ?? "",
                text: text,
                card: cardType,
                eventType: eventType
            )
            convertedEvents.append(convertedEvent)
        }
    }
}

extension OverViewVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if convertedEvents.isEmpty == true {
            overViewTableView.isHidden = true
            emptyImg.isHidden = false
        } else {
            overViewTableView.isHidden = false
            emptyImg.isHidden = true
        }
        
        return convertedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventUpdate = convertedEvents[indexPath.row]
        
        if self.t_1ID == eventUpdate.t_id {
            
            if eventUpdate.playerInName.isEmpty == false {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamA3Cell", for: indexPath) as? TeamA3Cell else {
                    return UITableViewCell()
                }
                cell.lblTime.text = "\(eventUpdate.time)'"
                cell.lblInPlayer.text = eventUpdate.playerInName
                cell.lblOutPlayer.text = eventUpdate.playerOutName
                
                cell.selectionStyle = .none
                return cell
            } else {
                if eventUpdate.card == "Goal" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamA2Cell", for: indexPath) as? TeamA2Cell else {
                        return UITableViewCell()
                    }
                    cell.lblTime.text = "\(eventUpdate.time)'"
                    cell.lblText.text = eventUpdate.text
                    
                    cell.selectionStyle = .none
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamA1Cell", for: indexPath) as? TeamA1Cell else {
                        return UITableViewCell()
                    }
                    cell.lblTime.text = "\(eventUpdate.time)'"
                    cell.lblText.text = eventUpdate.text
                    
                    if eventUpdate.card == "Yellow card" {
                        cell.img.image = UIImage(named: "YellowCard1")
                    } else if eventUpdate.card == "Red card" {
                        cell.img.image = UIImage(named: "RedCard1")
                    } else if eventUpdate.card == "Green card" {
                        cell.img.image = UIImage(named: "GreenCard1")
                    }
                    
                    cell.selectionStyle = .none
                    return cell
                }
            }
        } else {
            
            if eventUpdate.playerInName.isEmpty == false {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamB3Cell", for: indexPath) as? TeamB3Cell else {
                    return UITableViewCell()
                }
                cell.lblTime.text = "\(eventUpdate.time)'"
                cell.lblInPlayer.text = eventUpdate.playerInName
                cell.lblOutPlayer.text = eventUpdate.playerOutName
                
                cell.selectionStyle = .none
                return cell
            } else {
                if eventUpdate.card == "Goal" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamB2Cell", for: indexPath) as? TeamB2Cell else {
                        return UITableViewCell()
                    }
                    cell.lblTime.text = "\(eventUpdate.time)'"
                    cell.lblText.text = eventUpdate.text
                    
                    cell.selectionStyle = .none
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamB1Cell", for: indexPath) as? TeamB1Cell else {
                        return UITableViewCell()
                    }
                    cell.lblTime.text = "\(eventUpdate.time)'"
                    cell.lblText.text = eventUpdate.text
                    
                    if eventUpdate.card == "Yellow card" {
                        cell.img.image = UIImage(named: "YellowCard1")
                    } else if eventUpdate.card == "Red card" {
                        cell.img.image = UIImage(named: "RedCard1")
                    } else if eventUpdate.card == "Green card" {
                        cell.img.image = UIImage(named: "GreenCard1")
                    }
                    
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let event = convertedEvents[indexPath.row]
        if !event.playerInName.isEmpty && !event.playerOutName.isEmpty {
            return 80
        }
        return 58
    }
}
