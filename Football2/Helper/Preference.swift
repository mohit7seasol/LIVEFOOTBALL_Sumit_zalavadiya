//
//  Preference.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//

import UIKit

class Preference: NSObject {

    static let sharedInstance = Preference()
    
    let IS_SUBSCRIBE                      = "IS_SUBSCRIBE_KEY"
    let App_LANGUAGE_KEY                  = "AppLanguageKey"
    let FRIST_TIME                        = "FristTime"
    let APP_FRIST_TIME                        = "APP_FRIST_TIME"
    let SHOW_LANGUAGE                     = "SHOW_LANGUAGE"
    let SHOW_PARMISSION                   = "SHOW_PARMISSION"
    let SHOW_CONFIRM_PRIVACY_SCREEN       = "SHOW_CONFIRM_PRIVACY_SCREEN_KEY"
    let REPORT_COUNT                      = "REPORT_COUNT"
    let SHOW_DARKMODE                     = "SHOW_DARKMODE"
    let SHOW_RATE_US                      = "SHOW_RATE_US"
    let SHOW_GRID                         = "SHOW_GRID"
    let FILE_LIST                         = "FILE_LIST"
    let FOLDER_LIST                       = "FOLDER_LIST"
    let GET_STARTED                       = "GET_STARTED"
    let FASTMODE                       = "FASTMODE"
    let PASTE                       = "PASTE"
    let LANGUAGE                       = "LANGUAGE"
    let COUNTRYCODE                       = "COUNTRYCODE"
    let PassMode                       = "PassMode"
    
    
    let COUNTRY                         = "COUNTRY"
    let MESSAGE                       = "MESSAGE"
    let NAME                       = "NAME"
    let SCAN                       = "SCAN"
    let ABUTTON                       = "ABUTTON"
    let BBUTTON                        = "BBUTTON"
    let CBUTTON                      = "CBUTTON"
    let LanguageForFirstTime                      = "LanguageForFirstTime"
    
    // Method to set up defaults on first launch
        func setupDefaults() {
            let defaults = UserDefaults.standard
            
            // Check if this is the first launch
            if !defaults.bool(forKey: FRIST_TIME) {
                // Set PassMode to true by default on first install
                defaults.set(true, forKey: PassMode)
                // Mark that the app has been launched at least once
                defaults.set(true, forKey: FRIST_TIME)
            }
        }
}

func setDataToPreference(data: AnyObject, forKey key: String) {
    UserDefaults.standard.set(data, forKey: key)
    UserDefaults.standard.synchronize()
}

func getDataFromPreference(key: String) -> AnyObject? {
    return UserDefaults.standard.object(forKey: key) as AnyObject?
}

func removeDataFromPreference(key: String) {
    UserDefaults.standard.removeObject(forKey: key)
    UserDefaults.standard.synchronize()
}

func removeUserDefaultValues() {
    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.synchronize()
}

func setIsLanguageForFirstTime(isSet: Bool) {
    setDataToPreference(data: isSet as AnyObject, forKey: Preference.sharedInstance.LanguageForFirstTime)
}

func isLanguageForFirstTime() -> Bool {
    let isAccepted = getDataFromPreference(key: Preference.sharedInstance.LanguageForFirstTime)
    return isAccepted == nil ? false : (isAccepted as! Bool)
}


// MARK: - Subscribe Methods
func setIsUserSubscribe(isSubscribe: Bool) {
    setDataToPreference(data: isSubscribe as AnyObject, forKey: Preference.sharedInstance.IS_SUBSCRIBE)
}

func isUserSubscribe() -> Bool {
    let isAccepted = getDataFromPreference(key: Preference.sharedInstance.IS_SUBSCRIBE)
    return isAccepted == nil ? false : (isAccepted as! Bool)
}

// Show Language Screen

func setLanguageCode(str:String){
    UserDefaults.standard.set(str, forKey: Preference.sharedInstance.App_LANGUAGE_KEY)
}

func getLanguageCode() -> String{
    let code = UserDefaults.standard.object(forKey: Preference.sharedInstance.App_LANGUAGE_KEY) as? String
    if code == nil {
        return "en"
    }else{
        return code!
    }
}

// Show Intro Screen

func setIsFristTime(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.FRIST_TIME)
}

func isShowFristTime() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.FRIST_TIME)
    return status
}

func setIsAppFristTime(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.APP_FRIST_TIME)
}

func isShowAppFristTime() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.APP_FRIST_TIME)
    return status
}

// Show Parmission Screen

func setIsParmission(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_PARMISSION)
}

func isShowParmission() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_PARMISSION)
    return status
}

// Show Lan Screen

func setIsLanguage(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_LANGUAGE)
}

func isShowLanguage() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_LANGUAGE)
    return status
}


// Show Config Screen
func setIsShowConfirmPrivacyScreen(isShow: Bool) {
    setDataToPreference(data: isShow as AnyObject, forKey: Preference.sharedInstance.SHOW_CONFIRM_PRIVACY_SCREEN)
}

func isShowConfirmPrivacyScreen() -> Bool {
    let isAccepted = getDataFromPreference(key: Preference.sharedInstance.SHOW_CONFIRM_PRIVACY_SCREEN)
    return isAccepted == nil ? false : (isAccepted as! Bool)
}


// Show Intro Screen

func setIsDarkMode(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_DARKMODE)
}

func isShowDarkMode() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_DARKMODE)
    return status
}


// Show Rate Us Screen

func setIsGrid(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_RATE_US)
}

func isShowGrid() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_RATE_US)
    return status
}

// Show Grid Screen

func setIsRateUS(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_GRID)
}

func isShowRateUs() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_GRID)
    return status
}

// Set Ads ID

func setAdsModal(modal:AdsModal){
    UserDefaults().set(encodable: modal, forKey: "AdsModal")
}

func getAdsModal() -> AdsModal{
    if let modal = UserDefaults().get(AdsModal.self, forKey: "AdsModal"){
        return modal
    }
    return AdsModal()
}


func setGmpOpenId(_ id: String) {
        UserDefaults.standard.set(id, forKey: "gmpOpenId")
    }
func getGmpOpenId() -> String? {
    return UserDefaults.standard.string(forKey: "gmpOpenId")
}


// Show Grid Screen

func setGetStared(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.GET_STARTED)
}

func isGetStared() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.GET_STARTED)
    return status
}

//Faste Mode
func setFastMode(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.FASTMODE)
}

func isFastMode() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.FASTMODE)
    return status
}


//Paste Mode
func setPasteMode(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.PASTE)
}

func isPasteMode() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.PASTE)
    return status
}


//Language
func setLanguage(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.LANGUAGE)
}

func isLanguage() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.LANGUAGE)
    return status
}


//CountryCode
func setCountryCode(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.COUNTRYCODE)
}

func isCountryCode() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.COUNTRYCODE)
    return status
}






func setCountry(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.COUNTRY)
}

func isCountry() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.COUNTRY)
    return status
}

func setMessage(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.MESSAGE)
}

func isMessage() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.MESSAGE)
    return status
}

func setName(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.NAME)
}

func isName() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.NAME)
    return status
}

func setScan(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SCAN)
}

func isScan() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SCAN)
    return status
}

func setAButton(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.ABUTTON)
}

func isAButton() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.ABUTTON)
    return status
}

func setBButton(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.BBUTTON)
}

func isBButton() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.BBUTTON)
    return status
}

func setCButton(status:Bool){
    UserDefaults.standard.set(status, forKey: Preference.sharedInstance.CBUTTON)
}

func isCButton() -> Bool{
    let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.CBUTTON)
    return status
}
