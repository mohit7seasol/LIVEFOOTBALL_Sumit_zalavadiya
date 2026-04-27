//
//  MatchModels.swift
//  Football2
//
//  Created by Mohit Kanpara on 27/04/26.
//

import Foundation

enum MatchFilter {
    case live
    case scheduled
    case completed
}

struct Match {
    let matchId: String
    let leagueName: String
    let homeName: String
    let awayName: String
    let homeLogo: String
    let awayLogo: String
    let homeScore: Int?
    let awayScore: Int?
    let status: String
    let timestamp: Int
    let tournamentId: String
    let isStarted: Bool
    let isInProgress: Bool
    let isFinished: Bool
    let venueName: String?  // Added venue name property
    let venueCity: String?  // Added venue city property (optional)
    
    var formattedDateTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM • hh:mm a"
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Reference Code Models

struct MatchDetails {
    var leagueName: String = ""
    var homeName: String = ""
    var homeShortName: String = ""
    var awayName: String = ""
    var awayShortName: String = ""
    var homeLogo: String = ""
    var awayLogo: String = ""
    var homeScore: Int = 0
    var awayScore: Int = 0
    var status: String = ""
    var liveTime: String = ""
    var referee: String = ""
    var venueName: String = ""
    var venueCity: String = ""
    var attendance: String = ""
    var capacity: String = ""
    var timestamp: Int = 0
}

struct MatchStatModel {
    var name: String = ""
    var home: String = ""
    var away: String = ""
}

struct MatchSummaryEvent: Codable {
    let minutes: String?
    let team: String?
    let description: String?
    let players: [MatchSummaryPlayer]?
}

struct MatchSummaryPlayer: Codable {
    let name: String?
    let player_id: String?
    let player_url: String?
    let type: String?
    let sub_type: String?
}

struct H2HMatch: Codable {
    let match_id: String?
    let timestamp: Int?
    let status: String?
    let tournament_name: String?
    let tournament_name_short: String?
    let home_team: H2HTeam?
    let away_team: H2HTeam?
    let scores: H2HScore?
}

struct H2HScore: Codable {
    let home: String?
    let away: String?
}

struct H2HTeam: Codable {
    let name: String?
    let image_path: String?
}

struct Standing: Codable {
    let team_id: String?
    let team_url: String?
    let name: String?
    let matches_played: Int?
    let wins: Int?
    let draws: Int?
    let losses: Int?
    let goals: String?
    let goal_difference: Int?
    let points: Int?
}

// MARK: - Keep your existing models below
struct Country {
    let name: String
    let countryId: Int
    let country_url: String
}

struct Tournament {
    let name: String
    let url: String
}

struct TournamentMatchModel {
    let matchId: String
    let timestamp: Int
    let homeName: String
    let awayName: String
    let homeLogo: String
    let awayLogo: String
    let homeScore: Int
    let awayScore: Int
    let leagueId: String
    let leagueName: String
}
