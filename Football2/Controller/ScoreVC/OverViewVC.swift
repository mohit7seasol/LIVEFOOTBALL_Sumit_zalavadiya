//
//  OverViewVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

struct MatchOverviewResponse: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let result: MatchResultOverView
}

struct MatchResultOverView: Codable {
    let m_id: String
    let t1_id: Int
    let t1_name: String
    let t2_id: Int
    let t2_name: String
    let events_updates: [EventUpdate]
}

struct EventUpdate: Codable {
    let time: Int
    let t_id: Int
    let playerInName: String
    let playerOutName: String
    let text: String
    let card: String
    
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
    var eventsUpdates = [EventUpdate]()
    
    var t_1ID:Int?
    var t_2ID:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMatchOverview { [weak self] updates in
            self?.eventsUpdates = updates
            self?.overViewTableView.reloadData()
        }
    }
    
    func fetchMatchOverview(completion: @escaping ([EventUpdate]) -> Void) {
        guard let url = URL(string: matchOverView) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = ["m_id": m_id!]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let responseObject = try JSONDecoder().decode(MatchOverviewResponse.self, from: data)
                let eventsUpdates = responseObject.result.events_updates
                self.t_1ID = responseObject.result.t1_id
                self.t_2ID = responseObject.result.t2_id
                DispatchQueue.main.async {
                    completion(eventsUpdates)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    
}

extension OverViewVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if eventsUpdates.isEmpty == true {
            overViewTableView.isHidden = true
            emptyImg.isHidden = false
        } else {
            overViewTableView.isHidden = false
            emptyImg.isHidden = true
        }
        
        return eventsUpdates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventUpdate = eventsUpdates[indexPath.row]
        
        if self.t_1ID != eventUpdate.t_id {
            
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
                    } else {
                        
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
                    } else {
                        
                    }
                    
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
}
