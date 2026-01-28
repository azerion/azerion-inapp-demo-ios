import BlueStackSDK

/// View model for managing banner ad lifecycle and state
/// Conforms to InlineAdViewModel protocol for use in table/collection views
class BannerAdViewModel: NSObject, InlineAdViewModel {
    
    /// Represents the current loading state of the banner ad
    enum AdLoadState {
        case none       // Ad has not been loaded yet
        case loading    // Ad is currently loading
        case loaded     // Ad has successfully loaded
    }
    
    /// The placement ID that identifies the ad unit in the BlueStack dashboard
    var placementId: String
    
    /// The size of the banner ad (e.g., .banner, .mediumRectangle, .leaderboard)
    var adSize: AdSize
    
    /// The view controller that will present the ad
    weak var viewController: UIViewController?
    
    /// Callback triggered when the ad successfully loads
    /// Use this to update UI or reload table view cells
    var onAdLoaded: (() -> Void)?
    
    /// The BannerView instance from BlueStack SDK
    private var bannerView: BannerView?
    
    /// Current loading state of the ad
    private var adLoadState: AdLoadState = .none

    /// Initializes a new banner ad view model
    /// - Parameters:
    ///   - adSize: The size of the banner ad to display
    ///   - placementId: The placement ID from BlueStack dashboard
    init(adSize: AdSize, placementId: String) {
        self.adSize = adSize
        self.placementId = placementId
    }
    
    /// Loads the banner ad
    /// This method should be called when you want to request an ad from the server
    func loadAd() {
        // Update state to loading
        self.adLoadState = .loading
        
        // Clean up any existing banner ad instance before creating a new one
        if bannerView != nil {
            bannerView = nil
        }
        
        // Step 1: Create a BannerView instance with the specified ad size
        self.bannerView = BannerView(adSize: self.adSize)
        
        // Step 2: Set the placement ID
        // The placement ID identifies the ad unit in the BlueStack dashboard
        self.bannerView?.placementID = self.placementId
        
        // Step 3: Set the view controller
        // This is required for the SDK to properly handle ad interactions
        self.bannerView?.viewController = self.viewController
        
        // Step 4: Set the BannerViewDelegate to receive ad lifecycle callbacks
        // This delegate handles onLoad, onFailedToLoad, onRefresh, and onFailedToRefresh events
        self.bannerView?.delegate = self
        
        // Step 5: Load the banner ad with optional RequestOptions
        // The load() method initiates an ad request to the ad server
        // RequestOptions are optional - pass nil if you don't need targeting parameters
        self.bannerView?.load(requestOptions: prepareRequestOptions())
    }
    
    /// Checks if the ad has successfully loaded
    /// - Returns: true if the ad is loaded and ready to display, false otherwise
    func isAdLoaded() -> Bool {
        return self.adLoadState == .loaded
    }
    
    /// Returns the banner view for display
    /// - Returns: The UIView containing the loaded banner ad, or nil if not loaded
    func getView() -> UIView? {
        return self.bannerView
    }
    
    /// Destroys the banner ad and cleans up all resources
    /// Call this method when you want to permanently remove the ad
    func destroyAd() {
        Logger.debug("Destroying banner ad")
        
        // Clean up delegate and banner view
        bannerView?.delegate = nil
        bannerView = nil
        
        // Reset state
        adLoadState = .none
        
        // Clear callback
        onAdLoaded = nil
    }
    
    /// Stops refreshing banner ad.
    func stopRefresh() {
        bannerView?.stopAutoRefresh()
    }
    
    /// Starts refreshing banner ad after every certain interval.
    func startRefresh() {
        bannerView?.startAutoRefresh()
    }
    
    /// Creates and returns RequestOptions for ad targeting
    /// These parameters help deliver more relevant ads to users
    private func prepareRequestOptions() -> RequestOptions {
        let requestOptions = RequestOptions(
            age: 25,
            location: CLLocation.init(latitude: 48.87610, longitude: 10.453),
            gender: .male,
            keyword: "brand=myBrand;category=sport",
            contentUrl: "https://my_content_url.com/")
        return requestOptions
    }

    deinit {
        // Step 6: Clean up the banner ad when the view model is deallocated
        // This prevents memory leaks and ensures proper resource cleanup
        bannerView?.delegate = nil
        bannerView = nil
    }
}

// MARK: - BannerViewDelegate
extension BannerAdViewModel: BannerViewDelegate {
    
    /// Called when the banner ad has successfully loaded
    /// - Parameters:
    ///   - bannerView: The BannerView instance that loaded successfully
    ///   - preferredHeight: The preferred height for the banner ad
    /// - Note: The ad is now ready to be displayed
    func onLoad(_ bannerView: BlueStackSDK.BannerView, _ preferredHeight: CGFloat) {
        Logger.debug("Banner ad loaded successfully with preferred height: \(preferredHeight)")
        self.adLoadState = .loaded
        
        // Notify observers that the ad has loaded
        // This is called on the main thread to ensure UI updates are safe
        DispatchQueue.main.async { [weak self] in
            self?.onAdLoaded?()
        }
    }
    
    /// Called when the banner ad failed to load
    /// - Parameters:
    ///   - bannerView: The BannerView instance that failed to load
    ///   - error: The error describing why the ad failed to load
    /// - Note: Consider implementing retry logic with exponential backoff
    func onFailedToLoad(_ bannerView: BlueStackSDK.BannerView, _ error: any Error) {
        self.adLoadState = .none
        Logger.error("Failed to load banner ad with error: \(error.localizedDescription)")
    }
    
    /// Called when the banner ad is refreshed
    /// - Parameter bannerView: The BannerView that was refreshed
    /// - Note: This is called when the ad content is updated automatically
    func onRefresh(_ bannerView: BlueStackSDK.BannerView) {
        Logger.debug("Banner ad refreshed")
    }
    
    /// Called when the banner ad failed to refresh
    /// - Parameters:
    ///   - bannerView: The BannerView that failed to refresh
    ///   - error: The error describing why the refresh failed
    func onFailedToRefresh(_ bannerView: BlueStackSDK.BannerView, _ error: any Error) {
        Logger.error("Failed to refresh banner ad with error: \(error.localizedDescription)")
    }
}
