//
//  SeriesModel.swift
//  Football2
//
//  Created by Mohit Kanpara on 28/04/26.
//

import Foundation

// MARK: - Series List Models
struct SeriesCountry: Codable {
    let name: String
    let countryId: Int
    let country_url: String
}

// MARK: - Tournaments Match List Models
struct TournamentMatch: Codable {
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

// MARK: - API Response Structures
struct TournamentIDsResponse: Codable {
    let tournament_template_id: String
    let season_id: String
}
