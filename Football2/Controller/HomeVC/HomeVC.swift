//
//  HomeVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 28/04/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import SVProgressHUD

class HomeVC: UIViewController {
    // Removed viewForNative outlet
    @IBOutlet weak var matchListCollection: UICollectionView!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var finishedButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var currentMonthLabel: UILabel!
    @IBOutlet weak var datepickerCollection: UICollectionView!
    @IBOutlet weak var stackHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewMatchTypes: UIStackView!
    @IBOutlet weak var noDataAvilableImageView: UIImageView!
    
    var index = -1
    var isAscending: Bool = true
    var isLiveAvailable: Bool = true
    var matchesUpcoming: [MatchUpcoming] = []
    
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    
    var newsData: News?
    var newsResults: [Result] = []
    var selectedPosts: [Post] = []
    var selectedCategoryIndex = 0
    
    // MARK: - Calendar Properties
    private var selectedDateIndex = -1
    private var calendar = Calendar.current
    private var currentDate = Date()
    private var selectedDate = Date()
    private var dates: [Date] = []
    
    // MARK: - Match Properties
    var allMatches: [Match] = []
    var currentFilter: MatchFilter = .live
    var matchesFiltered: [Match] = []
    
    // MARK: - Ad Properties
    private var isAdLoaded = false
    private var adContainerView: UIView?
    private var adSkeletonView: SkeletonCustomView3?
    private var shouldShowAd: Bool {
        return !isUserSubscribe() && isAdLoaded
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .Home)
        setupUI()
        setupCalendar()
        setupCollectionViews()
        setupButtons()
        setupSVProgressHUD()
        loadNativeAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMatches(for: selectedDate)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        updateButtonStates(selected: .live)
        updateMonthLabel()
        updateStackViewHeight()
        noDataAvilableImageView.isHidden = true
        todayButton.setTitle("Today".localized(), for: .normal)
        liveButton.setTitle("Live Updates".localized(), for: .normal)
        upcomingButton.setTitle("Upcoming".localized(), for: .normal)
        finishedButton.setTitle("Finished".localized(), for: .normal)
    }
    
    private func updateStackViewHeight() {
        if calendar.isDateInToday(selectedDate) {
            stackHeightConstant.constant = 49
            stackViewMatchTypes.isHidden = false
        } else {
            stackHeightConstant.constant = 0
            stackViewMatchTypes.isHidden = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupSVProgressHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setForegroundColor(.white)
        SVProgressHUD.setBackgroundColor(UIColor.black.withAlphaComponent(0.7))
        SVProgressHUD.setRingThickness(4.0)
        SVProgressHUD.setRingRadius(20.0)
    }
    
    private func updateButtonStates(selected: MatchFilter) {
        let selectedColor = UIColor(hex: "#16C924")
        let unselectedColor = UIColor(hex: "#566D74")
        
        switch selected {
        case .live:
            liveButton.setTitleColor(selectedColor, for: .normal)
            upcomingButton.setTitleColor(unselectedColor, for: .normal)
            finishedButton.setTitleColor(unselectedColor, for: .normal)
        case .scheduled:
            liveButton.setTitleColor(unselectedColor, for: .normal)
            upcomingButton.setTitleColor(selectedColor, for: .normal)
            finishedButton.setTitleColor(unselectedColor, for: .normal)
        case .completed:
            liveButton.setTitleColor(unselectedColor, for: .normal)
            upcomingButton.setTitleColor(unselectedColor, for: .normal)
            finishedButton.setTitleColor(selectedColor, for: .normal)
        }
    }
    
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        currentMonthLabel.text = formatter.string(from: currentDate)
    }
    
    private func setupCalendar() {
        generateDatesForRange()
        updateMonthLabel()
        if let todayIndex = dates.firstIndex(where: { calendar.isDate($0, inSameDayAs: Date()) }) {
            selectedDateIndex = todayIndex
            selectedDate = dates[todayIndex]
        } else {
            selectedDateIndex = 0
            selectedDate = dates[0]
        }
        
        updateStackViewHeight()
        
        DispatchQueue.main.async {
            self.datepickerCollection.reloadData()
            self.datepickerCollection.scrollToItem(at: IndexPath(item: self.selectedDateIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    private func generateDatesForRange() {
        dates.removeAll()
        let today = Date()
        
        for i in -7...7 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
    }
    
    private func setToday() {
        currentDate = Date()
        selectedDate = Date()
        setupCalendar()
        fetchMatches(for: selectedDate)
    }
    
    private func setupCollectionViews() {
        // Datepicker Collection View
        datepickerCollection.register(UINib(nibName: "MatchDateCell", bundle: nil), forCellWithReuseIdentifier: "MatchDateCell")
        datepickerCollection.delegate = self
        datepickerCollection.dataSource = self
        datepickerCollection.showsHorizontalScrollIndicator = false
        datepickerCollection.backgroundColor = .clear
        
        if let layout = datepickerCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 0
        }
        
        // Match List Collection View - Register Ad Cell
        matchListCollection.register(UINib(nibName: "MatchListCell", bundle: nil), forCellWithReuseIdentifier: "MatchListCell")
        matchListCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "AdCell")
        matchListCollection.delegate = self
        matchListCollection.dataSource = self
        matchListCollection.backgroundColor = .clear
        matchListCollection.showsVerticalScrollIndicator = false
        
        if let layout = matchListCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
        }
        
        // Set content inset to match MatchListCell spacing
        matchListCollection.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 12, right: 10)
    }
    
    private func setupButtons() {
        liveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        upcomingButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        finishedButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        todayButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        todayButton.layer.cornerRadius = todayButton.frame.height / 2
        todayButton.layer.borderWidth = 1
        todayButton.layer.borderColor = UIColor(hex: "#16C924")?.cgColor
    }
    
    // MARK: - Native Ad Loading
    private func loadNativeAd() {
        guard !isUserSubscribe() else { return }
        
        showAdSkeleton()
        
        self.googleNativeAds.loadAds(self) { [weak self] nativeAdsTemp in
            DispatchQueue.main.async {
                self?.isAdLoaded = true
                self?.hideAdSkeleton()
                self?.matchListCollection.reloadData()
                
                // Create ad container and show ad
                if let adView = self?.createAdContainer() {
                    self?.googleNativeAds.showAdsView5(nativeAd: nativeAdsTemp, view: adView)
                }
            }
        }
        
        self.googleNativeAds.failAds(self) { [weak self] fail in
            DispatchQueue.main.async {
                self?.isAdLoaded = false
                self?.hideAdSkeleton()
                self?.matchListCollection.reloadData()
            }
        }
    }
    
    private func createAdContainer() -> UIView {
        // Calculate width with same padding as MatchListCell (left 10, right 10)
        let adWidth = matchListCollection.frame.width - 20 // 10 left + 10 right padding
        let container = UIView(frame: CGRect(x: 0, y: 0, width: adWidth, height: 200))
        container.backgroundColor = UIColor(named: "ADSBG") ?? UIColor(hex: "#F5F5F5")
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        adContainerView = container
        return container
    }
    
    private func showAdSkeleton() {
        if let skeletonView = Bundle.main.loadNibNamed("SkeletonCustomView3", owner: self, options: nil)?.first as? SkeletonCustomView3 {
            adSkeletonView = skeletonView
            skeletonView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set skeleton frame with proper width
            let adWidth = matchListCollection.frame.width - 20
            skeletonView.frame = CGRect(x: 0, y: 0, width: adWidth, height: 200)
            
            skeletonView.view1.showAnimatedGradientSkeleton()
            skeletonView.view2.showAnimatedGradientSkeleton()
            skeletonView.view3.showAnimatedGradientSkeleton()
            skeletonView.view4.showAnimatedGradientSkeleton()
            skeletonView.view5.showAnimatedGradientSkeleton()
        }
    }
    
    private func hideAdSkeleton() {
        adSkeletonView?.view1.hideSkeleton()
        adSkeletonView?.view2.hideSkeleton()
        adSkeletonView?.view3.hideSkeleton()
        adSkeletonView?.view4.hideSkeleton()
        adSkeletonView?.view5.hideSkeleton()
        adSkeletonView = nil
    }
    
    // MARK: - Match Fetching
    private func fetchMatches(for date: Date) {
        SVProgressHUD.show()
        
        noDataAvilableImageView.isHidden = true
        matchListCollection.isHidden = false
        
        FootballAPIService.shared.fetchMatches(for: date) { [weak self] matches in
            guard let self = self else {
                SVProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.allMatches = matches
                self.applyFilter()
                self.updateNoDataVisibility()
            }
        }
    }
    
    private func applyFilter() {
        if calendar.isDateInToday(selectedDate) {
            switch currentFilter {
            case .live:
                matchesFiltered = allMatches.filter { $0.isInProgress }
                    .sorted { $0.timestamp < $1.timestamp }
            case .scheduled:
                matchesFiltered = allMatches.filter { !$0.isStarted && !$0.isInProgress && !$0.isFinished }
                    .sorted { $0.timestamp < $1.timestamp }
            case .completed:
                matchesFiltered = allMatches.filter { $0.isFinished }
                    .sorted { $0.timestamp > $1.timestamp }
            }
        } else {
            matchesFiltered = allMatches
            if selectedDate < Date() {
                matchesFiltered.sort { $0.timestamp > $1.timestamp }
            } else {
                matchesFiltered.sort { $0.timestamp < $1.timestamp }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.matchListCollection.reloadData()
            self.updateNoDataVisibility()
        }
    }
    
    private func updateNoDataVisibility() {
        let hasMatches = !matchesFiltered.isEmpty
        
        if hasMatches {
            matchListCollection.isHidden = false
            noDataAvilableImageView.isHidden = true
        } else {
            matchListCollection.isHidden = true
            noDataAvilableImageView.isHidden = false
        }
    }
    
    private func handleDateSelection(at index: Int) {
        guard selectedDateIndex != index else { return }
        
        self.selectedDateIndex = index
        self.selectedDate = dates[index]
        
        updateStackViewHeight()
        self.fetchMatches(for: selectedDate)
        
        DispatchQueue.main.async {
            self.datepickerCollection.reloadData()
            self.datepickerCollection.scrollToItem(at: IndexPath(item: self.selectedDateIndex, section: 0), at: .centeredHorizontally, animated: true)
            self.matchListCollection.setContentOffset(.zero, animated: false)
        }
    }
}

// MARK: - Button Actions
extension HomeVC {
    @IBAction func todayButtonTap(_ sender: UIButton) {
        setToday()
    }
    
    @IBAction func liveButtonTap(_ sender: UIButton) {
        currentFilter = .live
        updateButtonStates(selected: .live)
        applyFilter()
    }
    
    @IBAction func upcomingButtonTap(_ sender: UIButton) {
        currentFilter = .scheduled
        updateButtonStates(selected: .scheduled)
        applyFilter()
    }
    
    @IBAction func finishedButtonTap(_ sender: UIButton) {
        currentFilter = .completed
        updateButtonStates(selected: .completed)
        applyFilter()
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == datepickerCollection {
            return dates.count
        } else {
            // Add 1 for ad cell if should show
            let matchCount = matchesFiltered.count
            return shouldShowAd ? matchCount + 1 : matchCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == datepickerCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchDateCell", for: indexPath) as! MatchDateCell
            let date = dates[indexPath.item]
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            
            let isSelected = (indexPath.item == selectedDateIndex)
            
            cell.dayNameLabel.text = dayFormatter.string(from: date).uppercased()
            cell.dateLabel.text = dateFormatter.string(from: date)
            cell.mainView.layer.cornerRadius = 10
            
            if isSelected {
                cell.mainView.backgroundColor = UIColor(hex: "#16C924")
                cell.dayNameLabel.textColor = .white
                cell.dateLabel.textColor = .white
            } else {
                cell.mainView.backgroundColor = .clear
                cell.dayNameLabel.textColor = UIColor(hex: "#566D74")
                cell.dateLabel.textColor = UIColor(hex: "#566D74")
            }
            
            return cell
        } else {
            // Check if this is the ad cell (first cell when ad should show)
            if shouldShowAd && indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdCell", for: indexPath)
                
                // Clear existing subviews
                cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                
                // Calculate ad width with same padding as match cells
                let adWidth = collectionView.frame.width - 20 // 10 left + 10 right
                
                // Add ad container or skeleton
                if let adContainer = adContainerView {
                    adContainer.frame = CGRect(x: 0, y: 0, width: adWidth, height: 200)
                    cell.contentView.addSubview(adContainer)
                } else if let skeletonView = adSkeletonView {
                    skeletonView.frame = CGRect(x: 0, y: 0, width: adWidth, height: 200)
                    cell.contentView.addSubview(skeletonView)
                } else {
                    // Create temporary skeleton if needed
                    let tempSkeleton = UIView(frame: CGRect(x: 0, y: 0, width: adWidth, height: 200))
                    tempSkeleton.backgroundColor = UIColor(named: "ADSBG") ?? UIColor(hex: "#F5F5F5")
                    tempSkeleton.layer.cornerRadius = 12
                    cell.contentView.addSubview(tempSkeleton)
                }
                
                cell.contentView.backgroundColor = .clear
                return cell
            }
            
            // Regular match cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchListCell", for: indexPath) as! MatchListCell
            let matchIndex = shouldShowAd ? indexPath.item - 1 : indexPath.item
            let match = matchesFiltered[matchIndex]
            
            cell.matchName.text = "\(match.homeName) VS \(match.awayName)"
            cell.dateTimeLabel.text = match.formattedDateTime
            
            loadTeamImages(homeLogo: match.homeLogo, awayLogo: match.awayLogo, cell: cell)
            cell.teamANameLabel.text = match.homeName
            cell.teamBNameLabel.text = match.awayName
            
            if calendar.isDateInToday(selectedDate) {
                switch currentFilter {
                case .live:
                    configureLiveCell(cell: cell, match: match)
                case .scheduled:
                    configureUpcomingCell(cell: cell, match: match)
                case .completed:
                    configureFinishedCell(cell: cell, match: match)
                }
            } else {
                if selectedDate < Date() {
                    configureFinishedCell(cell: cell, match: match)
                } else {
                    configureUpcomingCell(cell: cell, match: match)
                }
            }
            
            return cell
        }
    }
    
    private func configureLiveCell(cell: MatchListCell, match: Match) {
        cell.statusView.backgroundColor = UIColor(hex: "#DF1F1F")
        cell.statusLabel.text = "Live".localized()
        cell.scorLabel.isHidden = false
        if let homeScore = match.homeScore, let awayScore = match.awayScore {
            cell.scorLabel.text = "\(homeScore) - \(awayScore)"
        } else {
            cell.scorLabel.text = "0 - 0"
        }
    }
    
    private func configureUpcomingCell(cell: MatchListCell, match: Match) {
        cell.statusView.backgroundColor = UIColor(hex: "#1650BC")
        cell.statusLabel.text = "Upcoming".localized()
        cell.scorLabel.isHidden = true
        cell.scorLabel.text = ""
    }
    
    private func configureFinishedCell(cell: MatchListCell, match: Match) {
        cell.statusView.backgroundColor = UIColor(hex: "#04C057")
        cell.statusLabel.text = "Finished".localized()
        cell.scorLabel.isHidden = false
        if let homeScore = match.homeScore, let awayScore = match.awayScore {
            cell.scorLabel.text = "\(homeScore) - \(awayScore)"
        } else {
            cell.scorLabel.text = "0 - 0"
        }
    }
    
    private func loadTeamImages(homeLogo: String, awayLogo: String, cell: MatchListCell) {
        let placeholderImage = UIImage(named: "placeholder_flag")
        
        if let url = URL(string: homeLogo), !homeLogo.isEmpty {
            cell.teamAFlagImageView.sd_setImage(with: url, placeholderImage: placeholderImage)
        } else {
            cell.teamAFlagImageView.image = placeholderImage
        }
        
        if let url = URL(string: awayLogo), !awayLogo.isEmpty {
            cell.teamBFlagImageView.sd_setImage(with: url, placeholderImage: placeholderImage)
        } else {
            cell.teamBFlagImageView.image = placeholderImage
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == datepickerCollection {
            return CGSize(width: 60, height: 64)
        } else {
            // Use same width calculation for both ad and match cells
            let width = collectionView.frame.width - 20 // 10 left + 10 right
            
            // Check if this is the ad cell
            if shouldShowAd && indexPath.item == 0 {
                return CGSize(width: width, height: 200)
            }
            
            let height: CGFloat
            
            if calendar.isDateInToday(selectedDate) {
                switch currentFilter {
                case .live:
                    height = Device.isIpad ? 330 : 220
                case .scheduled:
                    height = Device.isIpad ? 280 : 190
                case .completed:
                    height = Device.isIpad ? 330 : 220
                }
            } else {
                if selectedDate < Date() {
                    height = Device.isIpad ? 330 : 220
                } else {
                    height = Device.isIpad ? 280 : 190
                }
            }
            
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == datepickerCollection {
            handleDateSelection(at: indexPath.item)
        } else {
            // Skip if ad cell is tapped
            if shouldShowAd && indexPath.item == 0 {
                return
            }
            
            showInterAd()
            let matchIndex = shouldShowAd ? indexPath.item - 1 : indexPath.item
            let match = matchesFiltered[matchIndex]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let scoreVC = storyboard.instantiateViewController(withIdentifier: "ScoreVC") as! ScoreVC
            
            scoreVC.m_idMain = match.matchId
            scoreVC.l_idMain = match.tournamentId
            scoreVC.m_name = match.leagueName
            scoreVC.Aname = match.homeName
            scoreVC.Bname = match.awayName
            scoreVC.Aimg = match.homeLogo
            scoreVC.Bimg = match.awayLogo
            
            if match.isInProgress {
                scoreVC.isMatchLive = true
                UpComing = false
            } else if match.isFinished {
                scoreVC.isMatchLive = false
                UpComing = false
            } else {
                UpComing = true
                scoreVC.isMatchLive = false
            }
            
            self.navigationController?.pushViewController(scoreVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == datepickerCollection {
            return 12
        } else {
            return 12
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == datepickerCollection {
            let totalCellWidth = 60 * CGFloat(dates.count)
            let totalSpacingWidth = 12 * CGFloat(dates.count - 1)
            let totalWidth = totalCellWidth + totalSpacingWidth
            let horizontalInset = (collectionView.frame.width - totalWidth) / 2
            
            if horizontalInset > 0 {
                return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
            } else {
                return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
        } else {
            // Remove inset here since we handle spacing in sizeForItemAt and contentInset
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}
