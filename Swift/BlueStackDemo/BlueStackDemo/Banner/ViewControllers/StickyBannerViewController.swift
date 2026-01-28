import UIKit
import BlueStackSDK
import CoreLocation

class StickyBannerViewController: UIViewController {
    
    @IBOutlet weak var bannerView: BannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadBanner()
    }
    
    private func loadBanner() {
        // Step 1: Set the placement ID
        // The placement ID identifies the ad unit in the BlueStack dashboard
        bannerView?.placementID = Constants.Placements.banner
        
        // Step 2: Set the BannerViewDelegate to receive ad lifecycle callbacks
        // This delegate handles onLoad, onFailedToLoad, onRefresh, and onFailedToRefresh events
        bannerView?.delegate = self
        
        // Step 3: Set the view controller
        // This is required for the SDK to properly handle ad interactions
        bannerView?.viewController = self
        
        // Step 4: Load the banner ad with optional RequestOptions
        // The load() method initiates an ad request to the ad server
        // RequestOptions are optional - pass nil if you don't need targeting parameters
        bannerView?.load(requestOptions: prepareRequestOptions())
    }
    
    /// Creates and returns RequestOptions for ad targeting
    /// These parameters help deliver more relevant ads to users
    /// - Returns: Configured RequestOptions with targeting parameters
    private func prepareRequestOptions() -> RequestOptions {
        let requestOptions = RequestOptions(
            age: 25,
            location: CLLocation(latitude: 48.87610, longitude: 10.453),
            gender: .male,
            keyword: "brand=myBrand;category=sport",
            contentUrl: "https://my_content_url.com/")
        return requestOptions
    }
    
    deinit {
        // Step 5: Clean up the banner ad when the view model is deallocated
        // This prevents memory leaks and ensures proper resource cleanup
        bannerView?.delegate = nil
        bannerView = nil
    }
}

// MARK: - BannerViewDelegate
extension StickyBannerViewController: BannerViewDelegate {
    
    /// Called when the sticky banner ad has successfully loaded
    /// - Parameters:
    ///   - bannerView: The BannerView instance that loaded successfully
    ///   - preferredHeight: The preferred height for the banner
    func onLoad(_ bannerView: BlueStackSDK.BannerView, _ preferredHeight: CGFloat) {
        Logger.debug("Banner loaded successfully with preferred height: \(preferredHeight)")
    }
    
    /// Called when the sticky banner ad failed to load
    /// - Parameters:
    ///   - bannerView: The BannerView instance that failed to load
    ///   - error: The error describing why the ad failed to load
    func onFailedToLoad(_ bannerView: BlueStackSDK.BannerView, _ error: any Error) {
        Logger.error("Failed to load banner with error: \(error.localizedDescription)")
    }
    
    /// Called when the sticky banner ad is refreshed
    /// - Parameter bannerView: The BannerView that was refreshed
    func onRefresh(_ bannerView: BlueStackSDK.BannerView) {
        Logger.debug("Banner refreshed")
    }
    
    /// Called when the sticky banner ad failed to refresh
    /// - Parameters:
    ///   - bannerView: The BannerView that failed to refresh
    ///   - error: The error describing why the refresh failed
    func onFailedToRefresh(_ bannerView: BlueStackSDK.BannerView, _ error: any Error) {
        Logger.error("Failed to refresh banner with error: \(error.localizedDescription)")
    }
    
    /// Called when the user clicks/taps on the sticky banner ad
    /// - Parameter bannerView: The BannerView that was clicked
    func onClick(_ bannerView: BannerView) {
        Logger.debug("Banner clicked")
    }
}
