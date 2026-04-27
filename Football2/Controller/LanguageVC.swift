//
//  LanguageVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import GoogleMobileAds

struct LanguageModel {
    var name: String
    var code: String
    var lan: String
}

class LanguageVC: UIViewController {

    @IBOutlet weak var langTableView: UITableView! {
        didSet {
            self.langTableView.register(UINib(nibName: "LangCell", bundle: nil), forCellReuseIdentifier: "LangCell")
            self.langTableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewBanner: GADBannerView!
    @IBOutlet weak var scrollBottom: NSLayoutConstraint!
    
    var isSelectedIndex = 0
    var arrLanguage: [LanguageModel] = [
        .init(name: "English", code: "en", lan: "(English)"),
        .init(name: "Hindi", code: "hi", lan: "(हिन्दी)"),
        .init(name: "German", code: "de", lan: "(Deutsch)"),
        .init(name: "Danish", code: "da", lan: "(Dansk)"),
        .init(name: "Italian", code: "it", lan: "(Italiana)"),
        .init(name: "Portuguese", code: "pt-PT", lan: "(Português)"),
        .init(name: "Spanish", code: "es", lan: "(Española)"),
        .init(name: "Turkish", code: "tr", lan: "(Türkçe)")
    ]
    
    var selectedLanguage = LanguageModel.init(name: "", code: "", lan: "")
    var previousLanguageCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .Language)
        self.previousLanguageCode = UserDefaults.standard.string(forKey: Preference.sharedInstance.App_LANGUAGE_KEY) ?? "en"
        self.selectedLanguage.code = UserDefaults.standard.string(forKey: Preference.sharedInstance.App_LANGUAGE_KEY) ?? "en"
        loadBannerAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedLanguageManage()
    }
    
    func selectedLanguageManage() {
        if selectedLanguage.code == "en" {
            isSelectedIndex = 0
        }
        else if selectedLanguage.code == "hi" {
            isSelectedIndex = 1
        }
        else if selectedLanguage.code == "de" {
            isSelectedIndex = 2
        }
        else if selectedLanguage.code == "da" {
            isSelectedIndex = 3
        }
        else if selectedLanguage.code == "it" {
            isSelectedIndex = 4
        }
        else if selectedLanguage.code == "pt-PT" {
            isSelectedIndex = 5
        }
        else if selectedLanguage.code == "es" {
            isSelectedIndex = 6
        }
        else if selectedLanguage.code == "tr" {
            isSelectedIndex = 7
        }
    }
    
    func loadBannerAd() {
           
            viewBanner.backgroundColor = .clear
           //        viewBanner = GADBannerView(adSize: GADAdSizeLargeBanner)
           viewBanner.adUnitID = bannerId //"ca-app-pub-3940256099942544/6300978111" // Test ad unit ID
           viewBanner.rootViewController = self
           viewBanner.delegate = self
           
           // Add banner to the view hierarchy
           viewBanner.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(viewBanner)
           
           // Set constraints to center the banner at the bottom
           NSLayoutConstraint.activate([
               viewBanner.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
               viewBanner.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
               viewBanner.widthAnchor.constraint(equalToConstant: 320),
               viewBanner.heightAnchor.constraint(equalToConstant: 100)
           ])
           
           // Load an ad
           let request = GADRequest()
           viewBanner.load(request)
       }
    
    
    @IBAction func doneTapped(_ sender: UIButton) {
        if isFromSplash {
                isFromSplash = false
                UserDefaults.standard.isAppLaunchFirstTime = false
                Bundle.setLanguage(lang: selectedLanguage.code)
                setLanguageCode(str: selectedLanguage.code)
                setIsLanguage(status: true)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    setLanguage(status: true)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "IntroMainVC") as! IntroMainVC
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } else {
                if selectedLanguage.code == previousLanguageCode {
                    print("Language not changed")
                    if isFromSettingsVC {
                        isFromSettingsVC = false
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        UserDefaults.standard.isAppLaunchFirstTime = false
                        Bundle.setLanguage(lang: selectedLanguage.code)
                        setLanguageCode(str: selectedLanguage.code)
                        setIsLanguage(status: true)
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            setLanguage(status: true)
                            AdsManager.shared.ShowInterstitialAD { }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeMainVC") as! HomeMainVC
                            self.navigationController?.pushViewController(vc, animated: false)
                        }
                    }
                } else {
                    Bundle.setLanguage(lang: selectedLanguage.code)
                    setLanguageCode(str: selectedLanguage.code)
                    setIsLanguage(status: true)
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        setLanguage(status: true)
                        AdsManager.shared.ShowInterstitialAD { }
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeMainVC") as! HomeMainVC
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            }
        }
        
    }

extension LanguageVC: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrLanguage.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LangCell") as! LangCell
            
            let lang = arrLanguage[indexPath.row]
            cell.iconImg.image = UIImage(named: lang.name)
            cell.langLbl.text = "\(lang.name) | \(lang.lan)"
            
            if indexPath.row == self.isSelectedIndex {
                cell.checkImg.image = UIImage(systemName: "checkmark.circle")
                cell.checkImg.tintColor = #colorLiteral(red: 0.01176470588, green: 0.8196078431, blue: 0.368627451, alpha: 1)
            } else {
                cell.checkImg.image = UIImage(systemName: "circle")
                cell.checkImg.tintColor = #colorLiteral(red: 0.5019607843, green: 0.5843137255, blue: 0.6156862745, alpha: 1)
            }
            
            cell.selectionStyle = .none
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.isSelectedIndex = indexPath.row
            self.selectedLanguage = arrLanguage[indexPath.row]
            langTableView.reloadData()
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 70
        }
    }

extension LanguageVC : GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        UIView.animate(withDuration: 0.5) {
            self.viewBanner.isHidden = false
            self.scrollBottom.constant = 100
        }
    }
    
    func bannerView(_ bannerView: GADBannerView,
                    didFailToReceiveAdWithError error: Error) {
        print("Failed to load banner ad: \(error.localizedDescription)")
        UIView.animate(withDuration: 0.5) {
            self.viewBanner.isHidden = true
            self.scrollBottom.constant = 0
        }
    }
}
