//
//  ScoreVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

struct MatchTabsResponse: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let result: ResultDataLive?
}

struct ResultDataLive: Codable {
    let t1_scr: Int?
    let t2_scr: Int?
    let t1_cornerKicks: Int?
    let t1_penalties: Int?
    let t1_redCards: Int?
    let t1_yellowCards: Int?
    let t2_cornerKicks: Int?
    let t2_penalties: Int?
    let t2_redCards: Int?
    let t2_yellowCards: Int?
    let result_str: String?
    let time: String?
}

class ScoreVC: BaseVC {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var matchTitleLbl: UILabel!
    @IBOutlet weak var viewForUpcomingScore: UIView!
    @IBOutlet weak var viewForOtherScores: UIView!
    
    @IBOutlet weak var imgA: UIImageView!
    @IBOutlet weak var lblA: UILabel!
    @IBOutlet weak var imgB: UIImageView!
    @IBOutlet weak var lblB: UILabel!
    
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblComplated: UILabel!
    
    @IBOutlet weak var lblT1Goal: UILabel!
    @IBOutlet weak var lblT1Rflag: UILabel!
    @IBOutlet weak var lblT1Yflag: UILabel!
    @IBOutlet weak var lblT1Kick: UILabel!
    
    @IBOutlet weak var lblT2Kick: UILabel!
    @IBOutlet weak var lblT2Yflag: UILabel!
    @IBOutlet weak var lblT2Rflag: UILabel!
    @IBOutlet weak var lblT2Goal: UILabel!
    
    @IBOutlet weak var topCollectionView: UICollectionView! {
        didSet {
            self.topCollectionView.register(UINib.init(nibName: "NewsCategoryCell", bundle: nil), forCellWithReuseIdentifier: "NewsCategoryCell")
        }
    }
    
    var m_idMain:String?
    var l_idMain:String?
    var m_name:String?
    var Aname:String?
    var Bname:String?
    var Aimg:String?
    var Bimg:String?
    var topArrray : [String] = []
    var index = 0
    var isMatchLive = false
    
    var refreshTimer: Timer?
    
    private var pagerVc: ScorePagerVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .MatchDetails)
        self.titleLbl.text = "Match Details"
        if UpComing == true {
            topArrray = [String.Squad, String.Info, String.PointTable]
            viewForUpcomingScore.isHidden = false
            viewForOtherScores.isHidden = true
        } else {
            topArrray = [String.LiveUpdate, String.Overview, String.Lineups, String.Stats, String.Squad, String.Info, String.PointTable]
            viewForUpcomingScore.isHidden = true
            viewForOtherScores.isHidden = false
        }
        self.setData()
        DispatchQueue.main.async {
            self.fetchMatchData()
            self.topCollectionView.reloadData()
        }
        startAutoRefresh()
    }
    
    func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.setData()
            DispatchQueue.main.async {
                self.fetchMatchData()
                self.topCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension ScoreVC {
    
    func setData() {
        DispatchQueue.main.async {
            if self.m_name?.isEmpty == false {
                self.matchTitleLbl.text = self.m_name
            } else {
                self.matchTitleLbl.text = ""
            }
            
            if self.Aname?.isEmpty == false {
                self.lblA.text = self.Aname
            } else {
                self.lblA.text = "TeamA"
            }
            
            if self.Bname?.isEmpty == false {
                self.lblB.text = self.Bname
            } else {
                self.lblB.text = "TeamB"
            }
            
            if self.Aimg?.isEmpty == false {
                let urlA = URL(string: self.Aimg!)
                self.imgA.sd_setImage(with: urlA, placeholderImage: UIImage(named: "DefaultFlag"))
            } else {
                self.imgA.image = UIImage(named: "DefaultFlag")!
            }
            
            if self.Bimg?.isEmpty == false {
                let urlA = URL(string: self.Bimg!)
                self.imgB.sd_setImage(with: urlA, placeholderImage: UIImage(named: "DefaultFlag"))
            } else {
                self.imgB.image = UIImage(named: "DefaultFlag")!
            }
        }
        
    }
    
    func fetchMatchData() {
        fetchMatchTabs { [weak self] result in
            guard let self = self, let result = result else { return }
            DispatchQueue.main.async {
                self.lblT1Goal.text = "\(result.t1_cornerKicks ?? 0)"
                self.lblT1Rflag.text = "\(result.t1_redCards ?? 0)"
                self.lblT1Yflag.text = "\(result.t1_yellowCards ?? 0)"
                self.lblT1Kick.text = "\(result.t1_penalties ?? 0)"
                
                self.lblScore.text = "\(result.t1_scr ?? 0) - \(result.t2_scr ?? 0)"
                self.lblComplated.text = "\(result.time ?? "") Completed"
                
                self.lblT2Goal.text = "\(result.t2_cornerKicks ?? 0)"
                self.lblT2Rflag.text = "\(result.t2_redCards ?? 0)"
                self.lblT2Yflag.text = "\(result.t2_yellowCards ?? 0)"
                self.lblT2Kick.text = "\(result.t2_penalties ?? 0)"
                
            }
        }
    }
    
    func fetchMatchTabs(completion: @escaping (ResultDataLive?) -> Void) {
        let url = URL(string: matchTab)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters = ["spt_typ": 2, "l_id": l_idMain!, "m_id": m_idMain!] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error:", error ?? "Unknown error")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(MatchTabsResponse.self, from: data)
                if response.status, let result = response.result {
                    completion(result)
                } else {
                    completion(nil)
                }
            } catch {
                print("JSON decoding error:", error)
                completion(nil)
            }
        }.resume()
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ScoreVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topArrray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCategoryCell", for: indexPath) as! NewsCategoryCell
        if indexPath.row == index {
            cell.categoryLbl.textColor = #colorLiteral(red: 0.02745098039, green: 0.831372549, blue: 0.3803921569, alpha: 1)
        } else {
            cell.categoryLbl.textColor = #colorLiteral(red: 0.5019999743, green: 0.5839999914, blue: 0.6159999967, alpha: 1)
        }
        cell.categoryLbl.text = topArrray[indexPath.item]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        index = indexPath.row
        collectionView.reloadData()
        
        if topArrray[indexPath.item] == String.LiveUpdate {
            pagerVc?.moveToPage(index: 0, animated: true)
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
            pagerVc?.isMatchLive = self.isMatchLive
            
        } else if topArrray[indexPath.item] == String.Overview {
            pagerVc?.moveToPage(index: 1, animated: true)
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
            
        } else if topArrray[indexPath.item] == String.Lineups {
            pagerVc?.moveToPage(index: 2, animated: true)
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
            
        } else if topArrray[indexPath.item] == String.Stats {
            pagerVc?.moveToPage(index: 3, animated: true)
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
            
        } else if topArrray[indexPath.item] == String.Squad {
            if UpComing == true {
                pagerVc?.moveToPage(index: 0, animated: true)
            } else {
                pagerVc?.moveToPage(index: 4, animated: true)
            }
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
            
        } else if topArrray[indexPath.item] == String.Info {
            if UpComing == true {
                pagerVc?.moveToPage(index: 1, animated: true)
            } else {
                pagerVc?.moveToPage(index: 5, animated: true)
            }
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
            
        } else if topArrray[indexPath.item] == String.PointTable {
            if UpComing == true {
                pagerVc?.moveToPage(index: 2, animated: true)
            } else {
                pagerVc?.moveToPage(index: 6, animated: true)
            }
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        //Where elements_count is the count of all your items in that
        //Collection view...
        let cellCount = CGFloat(topArrray.count)
        
        //If the cell count is zero, there is no point in calculating anything.
        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            
            //20.00 was just extra spacing I wanted to add to my cell.
            let totalCellWidth = cellWidth*cellCount + 20.00 * (cellCount-1)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            if (totalCellWidth < contentWidth) {
                //If the number of cells that exists take up less room than the
                //collection view width... then there is an actual point to centering them.
                
                //Calculate the right amount of padding to center the cells.
                let padding = (contentWidth - totalCellWidth) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            } else {
                //Pretty much if the number of cells that exist take up
                //more room than the actual collectionView width, there is no
                // point in trying to center them. So we leave the default behavior.
                //                if UpComing == true {
                //                    return UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 90)
                //                } else {
                return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                //                }
            }
            
        }
        return UIEdgeInsets.zero
    }
    
    
}


extension ScoreVC: ScoreOptionDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? ScorePagerVC {
            pagerVc = pageViewController
            pagerVc?.m_idMain = self.m_idMain
            pagerVc?.l_idMain = self.l_idMain
            pagerVc?.Aname = self.Aname
            pagerVc?.Bname = self.Bname
            pagerVc?.isMatchLive = self.isMatchLive
            pagerVc?.optionDelegate = self
        }
    }
    
    func didUpdateOptionIndex(currentIndex: Int) {
        
        if UpComing == true {
            
            if currentIndex == 0 {
                pagerVc?.moveToPage(index: 0, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            } else if currentIndex == 1 {
                pagerVc?.moveToPage(index: 1, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            } else if currentIndex == 2 {
                pagerVc?.moveToPage(index: 2, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            }
            
        } else {
            
            if currentIndex == 0 {
                pagerVc?.moveToPage(index: 0, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                pagerVc?.isMatchLive = self.isMatchLive
                
            } else if currentIndex == 1 {
                pagerVc?.moveToPage(index: 1, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            } else if currentIndex == 2 {
                pagerVc?.moveToPage(index: 2, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            } else if currentIndex == 3 {
                pagerVc?.moveToPage(index: 3, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            } else if currentIndex == 4 {
                pagerVc?.moveToPage(index: 4, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            } else if currentIndex == 5 {
                pagerVc?.moveToPage(index: 5, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            } else if currentIndex == 6 {
                pagerVc?.moveToPage(index: 6, animated: true)
                pagerVc?.m_idMain = self.m_idMain
                pagerVc?.l_idMain = self.l_idMain
                pagerVc?.Aname = self.Aname
                pagerVc?.Bname = self.Bname
                
            }
            
        }
    }
}
