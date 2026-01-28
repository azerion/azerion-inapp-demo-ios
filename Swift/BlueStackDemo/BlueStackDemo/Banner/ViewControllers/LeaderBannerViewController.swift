import UIKit
import BlueStackSDK

class LeaderBannerViewController: BaseBannerViewController {
    
    private var adViewModel: BannerAdViewModel!
    
    override func prepareInitialListData() -> [any ListItemViewModel] {
        adViewModel =  BannerAdViewModel(
            adSize: AdSize.leaderboard, placementId: Constants.Placements.banner
        )
        adViewModel.viewController = self
        return [
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
}
