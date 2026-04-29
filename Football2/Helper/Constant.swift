//
//  Constant.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import MBProgressHUD
import GoogleMobileAds

//MARK: - Global Variables

/// Privacy & Terms
let privacyPolicy  =  "https://sumit-zalavadiya.netlify.app/"
let termsOfUse     =  "https://sumit-zalavadiya.netlify.app/terms"
let eula           =  "https://sumit-zalavadiya.netlify.app/eula"
let REVIEW_LINK    = "https://itunes.apple.com/in/app/id\(APP_ID)?mt=8"
//
///// General flags
let isDevelopmentMode = true
let debug: Bool = true
let enableTestPremium = false    //To enable for testing set true
let hideBanerAdIfNotAvailable = true

let iTunesAppId   =  ""
let appStoreLink = "https://apps.apple.com/app/id\(APP_ID)"
let appBundleID  =   ""
let developerAppsLink = ""
var APITOKEN = "4c8a6959d4mshdda890c244de333p1a9559jsnfa944e297289"
var timeOffSet = ""
//

var APPNAME = "Football Score"
var APP_ID = "6745331768"
var instaAPI = ""
var addButtonColor = ""

var bannerId = "" //"ca-app-pub-3940256099942544/2934735716"
var nativeId = ""//"ca-app-pub-3940256099942544/3986624511"
var interstialId = ""//"ca-app-pub-3940256099942544/4411468910"
var appopenId = ""//"ca-app-pub-3940256099942544/5662855259"
var rewardId = ""
var fullScreenNativeId = ""
var inlineNativeBannerId = ""
var fullNativeAdsTemp: NativeAd?
var gamesURL = ""
var interFaild:Bool = false
var NativeFaild = false
var small_native = ""
var nativeId2 = ""
var NativeFailedToLoad = false
var fromScreen1:Bool = false

var adsCount = 0
var adsPlus = 0

let SERVER_ERROR = "Something went wrong please try agin sometime."
var isInterShow:Bool = false

var showint = 0
var loadint = 0
var sessionId = ""
var appopenClose:Bool = false
var firstTime:Bool = false

let PhotoUrl : String = "https://models.testingjunction.tech/public/uploads/"
//
//MARK: - live json
//     let getJSON  : String = "https://7seasol-application.s3.amazonaws.com/admin_prod/pbz-yvir-xvpx.json"
//MARK: - Also Change the Ad Id in the Splash for Full Native and Inlinne Native Banneer
////

//MARK: - test json
let getJSON : String = "https://7seasol-application.s3.amazonaws.com/admin_prod/pbz-grfgvat-arj.json" // "https://7seasol-application.s3.amazonaws.com/admin_prod/grfg.json"

//MARK: - Football APIs

var liveMatchAPI: String = "https://apis.sportstiger.com/Prod/get-live-matches"
var upcomingMatchAPI: String = "https://apis.sportstiger.com/Prod/get-upcoming-matches"
var resultMatchAPI: String = "https://apis.sportstiger.com/Prod/get-completed-matches"
var seriesMatchAPI: String = "https://apis.sportstiger.com/Prod/match-schedule"

var matchLiveUpdate:String = "https://apis.sportstiger.com/Prod/football-match-commentary"
var matchOverView:String = "https://apis.sportstiger.com/Prod/football-match-overview"
var matchInfo:String = "https://apis.sportstiger.com/Prod/match-info"
var matchSquad:String = "https://apis.sportstiger.com/Prod/match-squad"
var matchPointTbl:String = "https://apis.sportstiger.com/Prod/points-table"
var matchTab:String = "https://apis.sportstiger.com/Prod/get-match-tabs"
var matchStatsAPI:String = "https://apis.sportstiger.com/Prod/football-match-stats"
var matchLineUps:String = "https://apis.sportstiger.com/Prod/football-match-lineup"

var UpComing:Bool = false

extension String{
    
    static var LiveUpdate = "Live Update"
    static var Overview = "Overview"
    static let Lineups = "Lineups"
    static let Stats = "Stats"
    static let Squad = "Squad"
    static let Info = "Info"
    static let PointTable = "Point Table"
    static let HeadToHead = "Head2Head"
}

var appStart:Bool = false

public let ACCESS = "AKIA2FCATE7MLGSZBHML"

public let SECRET = "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"

let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
let MESSAGE_ERR_NETWORK = "No internet connection. Try again.."
var isfromeAppStart:Bool = false

public let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)

let globalColor = UIColor(red: 254/255, green: 205/255, blue: 51/255, alpha: 1)
let globalBGColor = UIColor(red: 254/255, green: 231/255, blue: 231/255, alpha: 1)
let globalGradientColor = #colorLiteral(red: 0.9921568627, green: 0.7843137255, blue: 0.1882352941, alpha: 1)

var selectMedia = false
var isAppOpenShow = false

var isFromSplash = false
var isFromSettingsVC = false
var selectedDecoderPriority = 1
var updatedTheme = "Light Mode"
var currentTheme = "Light Mode"
var userInterface = "light"
var isThemeVC = false
var isThemeChanged = false
var isFromPlaylistVC = false
var isFromEditingVC = false
var isShownRateDialog = false
var TYPE_STRING = ""
var closeInter:Bool = false

var InterFailed = false
var PremiumClose = false
var isInterShown = false

// UserDefaults keys
let cameraKey = "CameraPermissionEnabled"
let micKey = "MicPermissionEnabled"
let photoKey = "PhotoPermissionEnabled"

enum HapticFeedbackType {
    case impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(type: UINotificationFeedbackGenerator.FeedbackType)
    case selection
}

extension Notification.Name {
    
    static let isSave = Notification.Name("isSave")
    static let interFaild = Notification.Name("interFaild")
    static let forAlert = Notification.Name("forAlert")
    static let redyDownload = Notification.Name("redyDownload")
    static let closeAppopen = Notification.Name("closeAppopen")
    static let closeInter = Notification.Name("closeInter")
    static let closeOpen = Notification.Name("closeOpen")
    static let closePremium = Notification.Name("closePremium")
    
    static let appOpenClose = Notification.Name("appOpenClose")
    static let splashOpenClose = Notification.Name("splashOpenClose")
    static let splashOpenNill = Notification.Name("splashOpenNill")
    
    static let getOpenClose = Notification.Name("getOpenClose")
    static let getOpenNill = Notification.Name("getOpenNill")
    
    static let trimVideo = Notification.Name("trimVideo")
    static let splitVideo = Notification.Name("splitVideo")
    static let mp3Video = Notification.Name("mp3Video")
    
    static let selectMediaType = Notification.Name("selectMediaType")
    static let selectMediaTypeNil = Notification.Name("selectMediaTypeNil")
    static let languagePresent = Notification.Name("languagePresent")
    static let PremiumClose = Notification.Name("PremiumClose")
    
    
    static let step2Next = Notification.Name("step2Next")
    static let step3Next = Notification.Name("step3Next")
    static let step4Next = Notification.Name("step4Next")
    static let step5Next = Notification.Name("step5Next")
    static let step6Next = Notification.Name("step6Next")
    
    static let interstitialAdDidFail = Notification.Name("interstitialAdDidFail")
    static let interstitialAdDidDismiss = Notification.Name("interstitialAdDidDismiss")
}

enum HttpResponseStatusCode: Int {
    case ok = 200
    case badRequest = 400
    case noAuthorization = 401
}

//MARK: - Global Functions

func showAlertMessage(titleStr:String, messageStr:String) -> Void {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        UIApplication.shared.windows[0].rootViewController!.present(alert, animated: true, completion: nil)
    }
}

func showAlert(message: String, from viewController: UIViewController) {
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
    viewController.present(alert, animated: true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

func showAlert(message: String, from viewController: UIViewController, completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
    viewController.present(alert, animated: true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true, completion: {
                completion?()
            })
        }
    }
}

func triggerHapticFeedback(type: HapticFeedbackType) {
    switch type {
    case .impact(let style):
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
        
    case .notification(let notificationType):
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(notificationType)
        
    case .selection:
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}


func applyStroke(to label: UILabel, color: UIColor, width: CGFloat) {
    let attributedText = NSMutableAttributedString(string: label.text ?? "")
    attributedText.addAttributes([
        .strokeColor: color,
        .strokeWidth: -width // Negative value for stroke width
    ], range: NSRange(location: 0, length: attributedText.length))
    label.attributedText = attributedText
}

func getCurrentBadgeCount() -> Int {
    var badgeCount = 0
    
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.getPendingNotificationRequests { requests in
        // Count the number of notifications (or apply your own logic)
        badgeCount = requests.count
    }
    
    return badgeCount
}


func getDomainName(from urlString: String) -> String? {
    if let url = URL(string: urlString), let host = url.host {
        let components = host.components(separatedBy: ".")
        if components.count >= 2 {
            var domainName = components[components.count - 2]
            domainName = domainName.prefix(1).uppercased() + domainName.dropFirst()
            return domainName
        }
    }
    return nil
}

func downloadFavicon(from url: URL, iconImageView: UIImageView) {
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data, let faviconImage = UIImage(data: data) else {
            print("Error downloading favicon: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        DispatchQueue.main.async {
            iconImageView.image = faviconImage
        }
    }
    task.resume()
}

func convertTimestamp(_ timestamp: Int) -> (formattedDate: String, formattedTime: String, formattedDifference: String) {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    // Format the Date to "Saturday, 22 Jun"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, dd MMM"
    let formattedDate = dateFormatter.string(from: date)
    // Format the Date to "05:30AM"
    dateFormatter.dateFormat = "hh:mma"
    let formattedTime = dateFormatter.string(from: date)
    // Calculate the time difference from the current date and time
    let currentDate = Date()
    let difference = date.timeIntervalSince(currentDate)
    let differenceHours = Int(difference) / 3600
    let differenceMinutes = (Int(difference) % 3600) / 60
    let formattedDifference = String(format: "%02d:%02d", differenceHours, differenceMinutes)
    return (formattedDate, formattedTime, formattedDifference)
}

func ProgressViewHide(uiView: UIView) {
    
    DispatchQueue.main.async {
        uiView.isUserInteractionEnabled = true
        MBProgressHUD.hide(for: uiView, animated: true)
    }
}

