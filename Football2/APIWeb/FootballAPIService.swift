//
//  FootballAPIService.swift
//  Football2
//
//  Created by Mohit Kanpara on 27/04/26.
//

import Foundation
import Alamofire
import SwiftyJSON

class FootballAPIService {
    static let shared = FootballAPIService()
    
    private init() {}
    
    func fetchMatches(for date: Date, completion: @escaping ([Match]) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        
        let urlString = "https://flashscore4.p.rapidapi.com/api/flashscore/v2/matches/list-by-date?sport_id=1&date=\(dateStr)"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("flashscore4.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(APITOKEN, forHTTPHeaderField: "X-RapidAPI-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
                var matches: [Match] = []
                
                for tournament in json {
                    let leagueName = tournament["name"] as? String ?? ""
                    let tournamentId = tournament["tournament_id"] as? String ?? ""
                    
                    guard let matchesArray = tournament["matches"] as? [[String: Any]] else { continue }
                    
                    for matchData in matchesArray {
                        let home = matchData["home_team"] as? [String: Any]
                        let away = matchData["away_team"] as? [String: Any]
                        let scores = matchData["scores"] as? [String: Any]
                        let status = matchData["match_status"] as? [String: Any]
                        
                        // Parse venue information
                        let venue = matchData["venue"] as? [String: Any]
                        let venueName = venue?["name"] as? String ?? ""
                        let venueCity = venue?["city"] as? String ?? ""
                        
                        let match = Match(
                            matchId: matchData["match_id"] as? String ?? "",
                            leagueName: leagueName,
                            homeName: home?["name"] as? String ?? "",
                            awayName: away?["name"] as? String ?? "",
                            homeLogo: home?["smaill_image_path"] as? String ?? "",
                            awayLogo: away?["smaill_image_path"] as? String ?? "",
                            homeScore: scores?["home"] as? Int,
                            awayScore: scores?["away"] as? Int,
                            status: status?["stage"] as? String ?? "",
                            timestamp: matchData["timestamp"] as? Int ?? 0,
                            tournamentId: tournamentId,
                            isStarted: status?["is_started"] as? Bool ?? false,
                            isInProgress: status?["is_in_progress"] as? Bool ?? false,
                            isFinished: status?["is_finished"] as? Bool ?? false,
                            venueName: venueName,
                            venueCity: venueCity
                        )
                        
                        matches.append(match)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(matches)
                }
                
            } catch {
                print("JSON Parsing Error:", error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
}
