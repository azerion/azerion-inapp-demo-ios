import UIKit
import BlueStackSDK

class StandardBannerViewController: BaseBannerViewController {
    
    @IBOutlet weak var loadButton: GradientButton!
    @IBOutlet weak var toggleRefreshButton: GradientButton!
    @IBOutlet weak var removeButton: GradientButton!
    
    private var isRefreshEnabled = false
    private var isBannerRefreshResumable = false
    private var adViewModel: BannerAdViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeButton.isEnabled = false
        toggleRefreshButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isBannerRefreshResumable = isRefreshEnabled
        if isRefreshEnabled {
            adViewModel?.stopRefresh()
            isRefreshEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isRefreshEnabled = isBannerRefreshResumable
        if isBannerRefreshResumable {
            adViewModel?.startRefresh()
        }
    }
    
    override func prepareInitialListData() -> [any ListItemViewModel] {
        return [
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel(),
            DefaultPlaceholderViewModel()
        ]
    }

    @IBAction func loadButtonTapped(_ sender: GradientButton) {
        Logger.debug("Load button tapped - loading Standard Banner ad")
        configureAdViewModel()
        listItemViewModels.insert(adViewModel, at: 1)
        tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        loadButton.isEnabled = false
    }
    
    @IBAction func toggleRefreshButtonTapped(_ sender: GradientButton) {
        guard adViewModel?.isAdLoaded() ?? false else {
            Logger.warning("Cannot toggle refresh - ad has not been loaded yet")
            return
        }
        
        if isRefreshEnabled {
            Logger.debug("Stopping auto-refresh")
            adViewModel.stopRefresh()
            isRefreshEnabled = false
        } else {
            Logger.debug("Starting auto-refresh")
            adViewModel.startRefresh()
            isRefreshEnabled = true
        }
    }
    
    @IBAction func removeButtonTapped(_ sender: GradientButton) {
        removeBannerAd()
    }
    
    private func removeBannerAd() {
        guard adViewModel?.isAdLoaded() ?? false else {
            Logger.warning("Cannot remove ad - ad has not been loaded yet")
            return
        }
        
        Logger.debug("Removing and destroying Standard Banner ad")
        if let adIndex = listItemViewModels.firstIndex(where: { $0 is BannerAdViewModel }) {
            listItemViewModels.remove(at: adIndex)
            tableView.deleteRows(at: [IndexPath(row: adIndex, section: 0)], with: .fade)
        }
        
        // Destroy the banner ad to clean up resources
        adViewModel?.destroyAd()
        
        loadButton.isEnabled = true
        hideButton.isEnabled = false
        showButton.isEnabled = false
        toggleRefreshButton.isEnabled = false
        removeButton.isEnabled = false
        
        // Create a new ad view model for potential future loads
        adViewModel = BannerAdViewModel(adSize: .banner, placementId: Constants.Placements.banner)
        adViewModel.viewController = self
        setupAdViewModels()
    }
    
    private func configureAdViewModel() {
        adViewModel = BannerAdViewModel(
            adSize: AdSize.banner,
            placementId: Constants.Placements.banner
        )
        adViewModel.viewController = self
        adViewModel.onAdLoaded = { [weak self] in
            guard let self = self else { return }
            Logger.debug("Ad loaded, refreshing ad cell")
            if let adIndex = self.listItemViewModels.firstIndex(where: { $0 is BannerAdViewModel }) {
                let indexPath = IndexPath(row: adIndex, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            self.removeButton.isEnabled = true
            self.toggleRefreshButton.isEnabled = true
            hideButton.isEnabled = true
        }
    }
    
    deinit {
        Logger.debug("StandardBannerViewController deinitialized")
    }
}
