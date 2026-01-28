import UIKit
import BlueStackSDK

class MRECViewController: UIViewController {
    
    @IBOutlet weak var hideButton: GradientButton!
    @IBOutlet weak var showButton: GradientButton!
    @IBOutlet weak var tableView: UITableView!
        

    private var adViewModel: BannerAdViewModel!
    private var listItemViewModels: [any ListItemViewModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareListData()
        setupTableView()
        setupAdViewModel()
        hideButton.isEnabled = false
        showButton.isEnabled = false
    }
   
    private func prepareListData() {
        // Here we have created a single MREC ad to show in between list of items. You can create more and add it to your datasource dynamically.
        // Initialize the banner ad view model with MREC size and placement ID
        adViewModel = BannerAdViewModel(adSize: .mediumRectangle, placementId: Constants.Placements.mrec)
        adViewModel.viewController = self
        
        listItemViewModels = [
            DefaultPlaceholderViewModel(),
            adViewModel,
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
    
    private func setupTableView() {
        tableView.register(MRECTableViewCell.self, forCellReuseIdentifier: MRECTableViewCell.identifier())
        tableView.register(PlaceholderTableViewCell.self, forCellReuseIdentifier: PlaceholderTableViewCell.identifier())
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    

    private func setupAdViewModel() {
        adViewModel.onAdLoaded = { [weak self] in
            guard let self = self else { return }
            Logger.debug("Ad loaded, refreshing ad cell")
            hideButton.isEnabled = true
            if let adIndex = self.listItemViewModels.firstIndex(where: { $0 is BannerAdViewModel }) {
                let indexPath = IndexPath(row: adIndex, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    @IBAction func hideButtonPressed(_ sender: Any) {
        hideBannerAd()
    }

    @IBAction func showButtonPressed(_ sender: Any) {
        showBannerAd()
    }
    
    private func hideBannerAd() {
        Logger.debug("Hiding MREC banner ad")
        if let adIndex = listItemViewModels.firstIndex(where: { $0 is BannerAdViewModel }) {
            listItemViewModels.remove(at: adIndex)
            tableView.deleteRows(at: [IndexPath(row: adIndex, section: 0)], with: .fade)
        }
        hideButton.isEnabled = false
        showButton.isEnabled = true
    }
    
    private func showBannerAd() {
        Logger.debug("Showing MREC banner ad")
        listItemViewModels.insert(adViewModel, at: 1)
        tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        
        hideButton.isEnabled = true
        showButton.isEnabled = false
    }
    
    deinit {
        Logger.debug("MrecViewController deinitialized")
    }
}

extension MRECViewController: StoryboardInstantiable {}

// MARK: - UITableViewDataSource
extension MRECViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItemViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listItemViewModel = self.listItemViewModels[indexPath.row]
        var cellIdentifier = PlaceholderTableViewCell.identifier()
        if listItemViewModel is BannerAdViewModel {
            cellIdentifier = MRECTableViewCell.identifier()
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath) as! ListItemTableViewCell
        cell.configure(listItemViewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MRECViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
