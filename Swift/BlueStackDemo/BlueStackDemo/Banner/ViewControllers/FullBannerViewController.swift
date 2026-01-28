import UIKit
import BlueStackSDK

class FullBannerViewController: BaseBannerViewController {
    
    private var adViewModel: BannerAdViewModel!
    
    override func prepareInitialListData() -> [any ListItemViewModel] {
        adViewModel =  BannerAdViewModel(
            adSize: AdSize.fullBanner, placementId: Constants.Placements.banner
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
