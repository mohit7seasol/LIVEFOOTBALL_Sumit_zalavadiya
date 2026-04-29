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
    @IBOutlet weak var viewForNative: UIView!
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalyticAction(title: "", status: .Home)
        setupUI()
        setupCalendar()
        setupCollectionViews()
        setupButtons()
        subscribe()
        setupSVProgressHUD()
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
        // Initially hide no data image
        noDataAvilableImageView.isHidden = true
    }
    
    // MARK: - Update StackView Height Based on Selected Date
    private func updateStackViewHeight() {
        if calendar.isDateInToday(selectedDate) {
            // Today date - show stack view (height 49)
            stackHeightConstant.constant = 49
            stackViewMatchTypes.isHidden = false
        } else {
            // Other dates - hide stack view (height 0)
            stackHeightConstant.constant = 0
            stackViewMatchTypes.isHidden = true
        }
        
        // Animate the change
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
        
        // Update stack view height when calendar is set up
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
        
        // Match List Collection View
        matchListCollection.register(UINib(nibName: "MatchListCell", bundle: nil), forCellWithReuseIdentifier: "MatchListCell")
        matchListCollection.delegate = self
        matchListCollection.dataSource = self
        matchListCollection.backgroundColor = .clear
        matchListCollection.showsVerticalScrollIndicator = false
        
        if let layout = matchListCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
        }
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
    
    // MARK: - Match Fetching
    private func fetchMatches(for date: Date) {
        SVProgressHUD.show()
        
        // Show no data image initially
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
    
    // MARK: - Update No Data Visibility
    private func updateNoDataVisibility() {
        let hasMatches = !matchesFiltered.isEmpty
        
        if hasMatches {
            // Show collection view, hide no data image
            matchListCollection.isHidden = false
            noDataAvilableImageView.isHidden = true
        } else {
            // Hide collection view, show no data image
            matchListCollection.isHidden = true
            noDataAvilableImageView.isHidden = false
        }
    }
    
    private func handleDateSelection(at index: Int) {
        guard selectedDateIndex != index else { return }
        
        self.selectedDateIndex = index
        self.selectedDate = dates[index]
        
        // Update stack view height when date changes
        updateStackViewHeight()
        
        self.fetchMatches(for: selectedDate)
        
        DispatchQueue.main.async {
            self.datepickerCollection.reloadData()
            self.datepickerCollection.scrollToItem(at: IndexPath(item: self.selectedDateIndex, section: 0), at: .centeredHorizontally, animated: true)
            self.matchListCollection.setContentOffset(.zero, animated: false)
        }
    }
    
    func subscribe() {
        showSkeletonView()
        if Subscribe.get() == false {
            self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                print(" Home...Load Native ....")
                self.viewForNative.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.hideSkeletonView()
                    self.googleNativeAds.showAdsView6(nativeAd: nativeAdsTemp, view: self.viewForNative)
                }
            }
            
            self.googleNativeAds.failAds(self) { fail in
                print(" Home...Native fail....")
                self.viewForNative.isHidden = true
            }
            
        } else {
            self.hideSkeletonView()
            viewForNative.isHidden = true
        }
    }
    
    func showSkeletonView() {
        if let adView = Bundle.main.loadNibNamed("SkeletonCustomView3", owner: self, options: nil)?.first as? SkeletonCustomView3 {
            self.viewForNative.addSubview(adView)
            
            adView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: self.viewForNative.topAnchor),
                adView.leadingAnchor.constraint(equalTo: self.viewForNative.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: self.viewForNative.trailingAnchor),
                adView.bottomAnchor.constraint(equalTo: self.viewForNative.bottomAnchor)
            ])
            adView.view1.showAnimatedGradientSkeleton()
            adView.view2.showAnimatedGradientSkeleton()
            adView.view3.showAnimatedGradientSkeleton()
            adView.view4.showAnimatedGradientSkeleton()
            adView.view5.showAnimatedGradientSkeleton()
        }
    }
    
    func hideSkeletonView() {
        for subview in self.viewForNative.subviews {
            if let adView = subview as? SkeletonCustomView3 {
                adView.removeFromSuperview()
            }
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
            return matchesFiltered.count
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
            
            // Configure cell appearance
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchListCell", for: indexPath) as! MatchListCell
            let match = matchesFiltered[indexPath.item]
            
            // Configure match name
            cell.matchName.text = "\(match.homeName) VS \(match.awayName)"
            
            // Configure date and time from API
            cell.dateTimeLabel.text = match.formattedDateTime
            
            // Configure team flags and names
            loadTeamImages(homeLogo: match.homeLogo, awayLogo: match.awayLogo, cell: cell)
            cell.teamANameLabel.text = match.homeName
            cell.teamBNameLabel.text = match.awayName
            
            // Configure based on match status for current filter
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
        cell.statusLabel.text = "Live"
        cell.scorLabel.isHidden = false
        // Display score for live match
        if let homeScore = match.homeScore, let awayScore = match.awayScore {
            cell.scorLabel.text = "\(homeScore) - \(awayScore)"
        } else {
            cell.scorLabel.text = "0 - 0"
        }
    }
    
    private func configureUpcomingCell(cell: MatchListCell, match: Match) {
        cell.statusView.backgroundColor = UIColor(hex: "#1650BC")
        cell.statusLabel.text = "Upcoming"
        cell.scorLabel.isHidden = true
        cell.scorLabel.text = ""
    }
    
    private func configureFinishedCell(cell: MatchListCell, match: Match) {
        cell.statusView.backgroundColor = UIColor(hex: "#04C057")
        cell.statusLabel.text = "Finished"
        cell.scorLabel.isHidden = false
        // Display score for finished match
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
            // Fixed width with 10pt left and right spacing
            let width = collectionView.frame.width - 20
            let height: CGFloat
            
            if calendar.isDateInToday(selectedDate) {
                switch currentFilter {
                case .live:
                    height = 210
                case .scheduled:
                    height = 190
                case .completed:
                    height = 210
                }
            } else {
                if selectedDate < Date() {
                    height = 210
                } else {
                    height = 190
                }
            }
            
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == datepickerCollection {
            handleDateSelection(at: indexPath.item)
        } else {
            let match = matchesFiltered[indexPath.item]
            
            // Navigate to ScoreVC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let scoreVC = storyboard.instantiateViewController(withIdentifier: "ScoreVC") as! ScoreVC
            
            // Pass match data to ScoreVC
            scoreVC.m_idMain = match.matchId
            scoreVC.l_idMain = match.tournamentId
            scoreVC.m_name = match.leagueName
            scoreVC.Aname = match.homeName
            scoreVC.Bname = match.awayName
            scoreVC.Aimg = match.homeLogo
            scoreVC.Bimg = match.awayLogo
            
            // Determine if match is live, upcoming, or completed
            if match.isInProgress {
                scoreVC.isMatchLive = true
                UpComing = false
            } else if match.isFinished {
                scoreVC.isMatchLive = false
                UpComing = false
            } else {
                // Upcoming match
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
            return UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        }
    }
}
