//
//  AnalyticsWrapper.swift
//  File Manager
//
//  Created by 7SEASOL-6 on 13/08/24.
//

import Foundation
import FirebaseCore
import FirebaseAnalytics

enum AnalyticEvent: String {
    
    case Intro
    case Home
    case LiveMatches
    case UpcomingMatches
    case FinishedMatches
    case SeriesMatches
    case Games
    case MatchDetails
    case News
    case Settings
    case AboutUs
    case Language
    case PrivacyPolicy
    case TermsOfService
}

func logAnalyticView(title: String, Screen: String) {
    Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: title, AnalyticsParameterScreenClass: Screen])
}

func logAnalyticAction(title: String, status: AnalyticEvent) {
    Analytics.logEvent(status.rawValue, parameters: ["name": title, "status": status])
}

func logAnalyticActionWithParams(_ name: AnalyticEvent, parameters: [String : Any]?)
{
    Analytics.logEvent(name.rawValue, parameters: parameters)
}
