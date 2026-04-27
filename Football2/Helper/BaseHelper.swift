//
//  BaseHelper.swift
//  Browser
//
//  Created by Vraj Nakarani on 12/12/24.
//

import Foundation
import UIKit

enum UserDefaultsKeys {
    static let browserHistory = "BrowserHistory"
    static let browserTabs = "BrowserTabs"
}

struct WebURL: Codable{
    let url: String
    let listName: String
    let currentDate: String
}

struct BookMark: Codable{
    let url: String
    let listName: String
}


struct MainTabList: Codable, Equatable {  // Conform to Codable
    var tabID: String
    var image: Data
    var tabDetail: TabDetail
    
    static func == (lhs: MainTabList, rhs: MainTabList) -> Bool {
        return lhs.image == rhs.image && lhs.tabDetail == rhs.tabDetail
    }
}

struct TabDetail: Codable, Equatable {  // Conform to Codable
    var urls: [String]
}

struct BrowserBookMark: Codable{
    let id: String
    let url: String
    let currentDate: String
}



// MARK: - Welcome
struct News: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let result: [Result]
}

// MARK: - Result
struct Result: Codable {
    let title, slug: String
    let translations: Translations
    let posts, mainPost, otherPost: [Post]
    
    enum CodingKeys: String, CodingKey {
        case title, slug, translations, posts
        case mainPost = "main_post"
        case otherPost = "other_post"
    }
}

// MARK: - Post
struct Post: Codable {
    let title, slug, special: String
    let updatedAt, publishedAt: Int
    let media: Media
}

// MARK: - Media
struct Media: Codable {
    let alternativeText, title: String
    let src, thumbSrc: String
    
    enum CodingKeys: String, CodingKey {
        case alternativeText = "alternative_text"
        case title, src
        case thumbSrc = "thumb_src"
    }
}

// MARK: - Translations
struct Translations: Codable {
}

struct MoreApp{
    let secationName: String
    let subApp: [SubApp]
}

struct SubApp{
    let image: String
    let name: String
    let url: String
}

struct Language: Codable {
    let name: String
    let image: String
    let subName: String
    let lenguageCode: String
    var isSelected: Bool
    let color: String
}

struct SelectedLenguage: Codable{
    let index: Int
    let currentSelected: String
    let privuasSelected: String
    let currentCode: String
    let privuasCode: String
}


class BaseHelper {
    static var share = BaseHelper()
    
    
    func getWebURLList() -> [WebURL]?{
        let placeData = UserDefaults.standard.data(forKey: "list")
        if placeData != nil{
            let placeArray = try! JSONDecoder().decode([WebURL].self, from: placeData!)
            return placeArray
        }else{
        }
        return nil
    }
    
    
    
    
    func getBookmarkURLList() -> [BookMark]?{
        let placeData = UserDefaults.standard.data(forKey: "Bookmark")
        if placeData != nil{
            let placeArray = try! JSONDecoder().decode([BookMark].self, from: placeData!)
            return placeArray
        }else{
        }
        return nil
    }
    
    
    
    static func saveMainTabListArrayToUserDefaults(tabListArray: [MainTabList]) {
        do {
            let encodedData = try JSONEncoder().encode(tabListArray)
            UserDefaults.standard.set(encodedData, forKey: "mainTabListArray")
            UserDefaults.standard.synchronize()
        } catch {
            print("Failed to save MainTabList array:", error)
        }
    }
    
    // Load MainTabList array from UserDefaults
    static func loadMainTabListArrayFromUserDefaults() -> [MainTabList]? {
        guard let savedData = UserDefaults.standard.data(forKey: "mainTabListArray") else { return nil }
        do {
            let mainTabListArray = try JSONDecoder().decode([MainTabList].self, from: savedData)
            return mainTabListArray
        } catch {
            print("Failed to load MainTabList array:", error)
            return nil
        }
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
    
    func addMoreApp() -> [MoreApp]?{
        var section = [MoreApp]()
        
        var recommended = [SubApp]()
        var lifestyle = [SubApp]()
        var socialNetworking = [SubApp]()
        var finance = [SubApp]()
        var entertainment = [SubApp]()
        var newsReading = [SubApp]()
        var education = [SubApp]()
        
        recommended.append(SubApp(image: "ic_HotstarApp", name: "Hotstar", url: ""))
        recommended.append(SubApp(image: "ic_ZomatoApp", name: "Zomato", url: ""))
        recommended.append(SubApp(image: "ic_AJioApp", name: "Ajio", url: ""))
        recommended.append(SubApp(image: "ic_AmazonApp", name: "Amazon", url: ""))
        recommended.append(SubApp(image: "ic_bigbasketApp", name: "bigbasket", url: ""))
        recommended.append(SubApp(image: "ic_NaukriApp", name: "Naukri", url: ""))
        section.append(MoreApp(secationName: "Recommended", subApp: recommended))
        
        
        lifestyle.append(SubApp(image: "ic_MyntraApp", name: "Myntra", url: ""))
        lifestyle.append(SubApp(image: "ic_PharmEasyApp", name: "PharmEasy", url: ""))
        lifestyle.append(SubApp(image: "ic_GrofersApp", name: "Grofers", url: ""))
        lifestyle.append(SubApp(image: "ic_BookMyShowApp", name: "BookMyShow", url: ""))
        section.append(MoreApp(secationName: "Lifestyle", subApp: lifestyle))
        
        socialNetworking.append(SubApp(image: "ic_FacebookApp", name: "Facebook", url: ""))
        socialNetworking.append(SubApp(image: "ic_instagramApp", name: "Instagram", url: ""))
        socialNetworking.append(SubApp(image: "ic_MoreXApp", name: "Twitter", url: ""))
        socialNetworking.append(SubApp(image: "ic_YouTubeApp", name: "YouTube", url: ""))
        section.append(MoreApp(secationName: "Social Networking", subApp: socialNetworking))
        
        finance.append(SubApp(image: "ic_HDFCBankApp", name: "HDFC Bank", url: ""))
        finance.append(SubApp(image: "ic_MoreAxisBankApp", name: "Axis Bank", url: ""))
        finance.append(SubApp(image: "ic_AirtelApp", name: "Airtel Bank", url: ""))
        finance.append(SubApp(image: "ic_PolicybazaarApp", name: "Policybazaar", url: ""))
        section.append(MoreApp(secationName: "Finance", subApp: finance))
        
        entertainment.append(SubApp(image: "ic_GaanaApp", name: "Gaana", url: ""))
        entertainment.append(SubApp(image: "ic_PrimeVideoApp", name: "Prime Video", url: ""))
        entertainment.append(SubApp(image: "ic_MXPlayerApp", name: "MX Player", url: ""))
        entertainment.append(SubApp(image: "ic_NetflixApp", name: "Netflix", url: ""))
        entertainment.append(SubApp(image: "ic_JioChinemaApp", name: "JioCinema", url: ""))
        section.append(MoreApp(secationName: "Entertainment", subApp: entertainment))
        
        newsReading.append(SubApp(image: "ic_AajTakApp", name: "AajTak", url: ""))
        newsReading.append(SubApp(image: "ic_ABPNewsApp", name: "ABP News", url: ""))
        newsReading.append(SubApp(image: "ic_TheHinduApp", name: "The Hindu", url: ""))
        newsReading.append(SubApp(image: "ic_EconomictimesApp", name: "Economictimes", url: ""))
        section.append(MoreApp(secationName: "News & Reading", subApp: newsReading))
        
        education.append(SubApp(image: "ic_BYJUSApp", name: "BYJUS", url: ""))
        education.append(SubApp(image: "ic_UnacademyApp", name: "Unacademy", url: ""))
        education.append(SubApp(image: "ic_DoubtnutApp", name: "Doubtnut", url: ""))
        education.append(SubApp(image: "ic_VedantuApp", name: "Vedantu", url: ""))
        section.append(MoreApp(secationName: "Education", subApp: education))
        
        return section
    }
    
    func addLanguage() -> [Language]?{
        var data = [Language]()
        data.append(Language(name: "English", image: "ic_English", subName: "English", lenguageCode: "en", isSelected: true, color: "LanguageColor1"))
        data.append(Language(name: "Hindi", image: "ic_Hindi", subName: "हिंदी", lenguageCode: "hi", isSelected: true, color: "LanguageColor2"))
        data.append(Language(name: "Spanish", image: "ic_Spanish", subName: "Española", lenguageCode: "es", isSelected: true, color: "LanguageColor3"))
        data.append(Language(name: "German", image: "ic_German", subName: "Deutsch", lenguageCode: "de", isSelected: true, color: "LanguageColor4"))
        data.append(Language(name: "Italian", image: "ic_Italian", subName: "Italiano", lenguageCode: "it", isSelected: true, color: "LanguageColor5"))
        data.append(Language(name: "Turkish", image: "ic_Turkish", subName: "Türkçe", lenguageCode: "tr", isSelected: true, color: "LanguageColor6"))
        data.append(Language(name: "Portuguese", image: "ic_Portuguese", subName: "Português", lenguageCode: "pt-PT", isSelected: true, color: "LanguageColor7"))
        data.append(Language(name: "Danish", image: "ic_Danish", subName: "Dansk", lenguageCode: "da", isSelected: true, color: "LanguageColor8"))
        return data
    }

}
