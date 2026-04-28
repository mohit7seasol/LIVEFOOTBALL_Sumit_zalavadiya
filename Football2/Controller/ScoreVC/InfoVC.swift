//
//  InfoVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

class InfoVC: UIViewController {
    
    @IBOutlet weak var lblMatchName: UILabel!
    @IBOutlet weak var lblSeries: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblVenue: UILabel!
    
    var index = -1
    var m_id: String?
    var l_id: String?
    var matchDetails: MatchDetails?
    var titleArr: [String] = []
    var infoArr: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let details = matchDetails {
            updateUI(with: details)
        } else {
            fetchMatchDetails()
        }
    }
    
    func updateUI(with details: MatchDetails) {
        let result = convertTimestamp(details.timestamp)
        
        DispatchQueue.main.async {
            self.lblMatchName.text = details.leagueName
            self.lblSeries.text = details.homeName
            self.lblVenue.text = "\(details.venueName), \(details.venueCity)"
            self.lblDate.text = result.formattedDate
            self.lblTime.text = result.formattedTime
        }
    }
    
    // MARK: - Updated API from Reference Code
    func fetchMatchDetails() {
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/details?match_id=\(m_id ?? "")"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let tournament = json["tournament"] as? [String: Any]
                    let venue = json["venue"] as? [String: Any]
                    let timestamp = json["timestamp"] as? Int ?? 0
                    
                    let leagueName = tournament?["name"] as? String ?? ""
                    let venueName = venue?["name"] as? String ?? ""
                    let cityName = venue?["city"] as? String ?? ""
                    
                    let details = MatchDetails(
                        leagueName: leagueName,
                        homeName: "",
                        homeShortName: "",
                        awayName: "",
                        awayShortName: "",
                        homeLogo: "",
                        awayLogo: "",
                        homeScore: 0,
                        awayScore: 0,
                        status: "",
                        liveTime: "",
                        referee: "",
                        venueName: venueName,
                        venueCity: cityName,
                        attendance: "",
                        capacity: "",
                        timestamp: timestamp
                    )
                    
                    DispatchQueue.main.async {
                        self?.updateUI(with: details)
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func convertTimestamp(_ timestamp: Int) -> (formattedDate: String, formattedTime: String) {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMM"
        let formattedDate = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "hh:mm a"
        let formattedTime = dateFormatter.string(from: date)
        return (formattedDate, formattedTime)
    }
}
