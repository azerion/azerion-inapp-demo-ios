import UIKit
import BlueStackSDK

class BaseBannerViewController: UIViewController {
    
    @IBOutlet weak var hideButton: GradientButton!
    @IBOutlet weak var showButton: GradientButton!
    @IBOutlet weak var tableView: UITableView!
    
    var listItemViewModels: [any ListItemViewModel]!
    
    private var hiddenAdViewModels: [(ad: BannerAdViewModel, originalPosition: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listItemViewModels = prepareInitialListData()
        setupTableView()
        setupAdViewModels()
        configureInitialButtonStates()
    }
    
    func prepareInitialListData() -> [any ListItemViewModel] {
        fatalError("Subclasses must override prepareInitialListData()")
    }
    
    private func setupTableView() {
        tableView.register(BannerTableViewCell.self, forCellReuseIdentifier: BannerTableViewCell.identifier())
        tableView.register(PlaceholderTableViewCell.self, forCellReuseIdentifier: PlaceholderTableViewCell.identifier())
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupAdViewModels() {
        let adViewModels = listItemViewModels.compactMap { $0 as? BannerAdViewModel }
        for adViewModel in adViewModels {
            adViewModel.onAdLoaded = { [weak self] in
                guard let self = self else { return }
                Logger.debug("Ad loaded, refreshing ad cell")
                self.onAdLoaded()
                self.refreshAdCell(for: adViewModel)
            }
        }
    }
    
    private func refreshAdCell(for adViewModel: BannerAdViewModel) {
        if let adIndex = listItemViewModels.firstIndex(where: {
            ($0 as? BannerAdViewModel) === adViewModel
        }) {
            let indexPath = IndexPath(row: adIndex, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func configureInitialButtonStates() {
        showButton?.isEnabled = false
        hideButton?.isEnabled = false
    }
    
    func onAdLoaded() {
        hideButton?.isEnabled = true
    }
    
    @IBAction func hideButtonPressed(_ sender: GradientButton) {
        hideAllBannerAds()
    }
    
    @IBAction func showButtonPressed(_ sender: GradientButton) {
        showAllBannerAds()
    }
    
    private func hideAllBannerAds() {
        guard let adsWithPositions = collectVisibleAdsWithPositions() else {
            return
        }
        
        let indexPathsToDelete = removeAdsFromList(adsWithPositions)
        
        tableView.deleteRows(at: indexPathsToDelete, with: .fade)
        
        hideButton?.isEnabled = false
        showButton?.isEnabled = true
    }
    
    private func collectVisibleAdsWithPositions() -> [(ad: BannerAdViewModel, originalPosition: Int)]? {
        let visibleAds = listItemViewModels.compactMap { $0 as? BannerAdViewModel }
        
        guard !visibleAds.isEmpty else {
            Logger.warning("No ads to hide")
            return nil
        }
        
        guard visibleAds.contains(where: { $0.isAdLoaded() }) else {
            Logger.warning("Cannot hide ads - no ads have been loaded yet")
            return nil
        }
        
        Logger.debug("Hiding all banner ads (\(visibleAds.count) ads)")
        
        var adsWithPositions: [(ad: BannerAdViewModel, originalPosition: Int)] = []
        
        for adViewModel in visibleAds {
            if let index = listItemViewModels.firstIndex(where: {
                ($0 as? BannerAdViewModel) === adViewModel
            }) {
                adsWithPositions.append((ad: adViewModel, originalPosition: index))
            }
        }
        
        return adsWithPositions
    }
    
    private func removeAdsFromList(_ adsWithPositions: [(ad: BannerAdViewModel, originalPosition: Int)]) -> [IndexPath] {
        hiddenAdViewModels = adsWithPositions.sorted { $0.originalPosition < $1.originalPosition }
        
        let sortedForRemoval = adsWithPositions.sorted { $0.originalPosition > $1.originalPosition }
        
        var indexPathsToDelete: [IndexPath] = []
        
        for item in sortedForRemoval {
            if let currentIndex = listItemViewModels.firstIndex(where: {
                ($0 as? BannerAdViewModel) === item.ad
            }) {
                listItemViewModels.remove(at: currentIndex)
                indexPathsToDelete.append(IndexPath(row: currentIndex, section: 0))
            }
        }
        
        return indexPathsToDelete
    }
    
    private func showAllBannerAds() {
        guard canShowAds() else {
            return
        }
        
        let indexPathsToInsert = insertAdsIntoList()
        
        tableView.insertRows(at: indexPathsToInsert, with: .fade)
        
        hideButton?.isEnabled = true
        showButton?.isEnabled = false
    }
    
    
    private func canShowAds() -> Bool {
        guard !hiddenAdViewModels.isEmpty else {
            Logger.warning("No hidden ads to show")
            return false
        }
        
        guard hiddenAdViewModels.contains(where: { $0.ad.isAdLoaded() }) else {
            Logger.warning("Cannot show ads - no ads have been loaded yet")
            return false
        }
        
        return true
    }
    
    private func insertAdsIntoList() -> [IndexPath] {
        Logger.debug("Showing all banner ads (\(hiddenAdViewModels.count) ads)")
        
        for item in hiddenAdViewModels {
            let insertIndex = min(item.originalPosition, listItemViewModels.count)
            listItemViewModels.insert(item.ad, at: insertIndex)
        }
        
        let indexPathsToInsert = hiddenAdViewModels.map {
            IndexPath(row: $0.originalPosition, section: 0)
        }
        
        hiddenAdViewModels.removeAll()
        
        return indexPathsToInsert
    }
    
    deinit {
        Logger.debug("\(String(describing: type(of: self))) deinitialized")
    }
}

extension BaseBannerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItemViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listItemViewModel = self.listItemViewModels[indexPath.row]
        var cellIdentifier = PlaceholderTableViewCell.identifier()
        if listItemViewModel is BannerAdViewModel {
            cellIdentifier = BannerTableViewCell.identifier()
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath) as! ListItemTableViewCell
        cell.configure(listItemViewModel)
        return cell
    }
}

extension BaseBannerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BaseBannerViewController: StoryboardInstantiable {}
