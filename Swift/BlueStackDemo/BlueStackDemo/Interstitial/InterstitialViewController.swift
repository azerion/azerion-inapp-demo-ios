import UIKit
import BlueStackSDK

class InterstitialViewController: UIViewController {
    
    @IBOutlet weak var showInterstitialButton: GradientButton!
    @IBOutlet weak var loadInterstitialButton: GradientButton!
    @IBOutlet weak var tableView: UITableView!
    
    var interstitialAd: InterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInterstitialButton.isEnabled = false
    }
    
    @IBAction func loadInterstitialButtonPressed(_ sender: Any) {
        initializeInterstitialAd()
        loadInterstitialAd()
        self.loadInterstitialButton.isEnabled = false
        self.showInterstitialButton.isEnabled = false
    }
    
    
    @IBAction func showInterstitialButtonPressed(_ sender: Any) {
        // Step 6: Check if the ad is ready and show it
        // Ensure if the ad is ready to be displayed using isReady() before calling show()
        // The show() method presents the full-screen interstitial ad
        // The FullScreenDelegate callbacks will be triggered during the ad lifecycle
        if interstitialAd?.isReady ?? false {
            interstitialAd?.show(fromRootViewController: self)
        }
    }
    
    private func initializeInterstitialAd() {
        // Clean up any existing interstitial ad instance before creating a new one
        if interstitialAd != nil {
            interstitialAd = nil
        }
        
        // Step 1: Create an InterstitialAd instance with your placement ID
        // The placement ID identifies the ad unit in the BlueStack dashboard
        interstitialAd = InterstitialAd(placementID: Constants.Placements.interstitial)
        
        // Step 2: Set the InterstitialAdDelegate to receive ad lifecycle callbacks
        // This delegate handles onAdLoaded and onAdFailedToLoad events
        interstitialAd?.delegate = self
        
        // Step 3: Set the FullScreenDelegate to receive display-related callbacks
        // This delegate handles onAdDisplayed, onAdFailedToDisplay, onAdClicked, and onAdDismissed events
        interstitialAd?.fullScreenDelegate = self
        
        // Step 4: Set the view controller
        // This is required for the SDK to properly display the full-screen content on click
        interstitialAd?.viewController = self
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
    
    private func loadInterstitialAd() {
        // Step 5: Load the interstitial ad with optional RequestOptions
        // The load() method initiates an ad request to the ad server
        // RequestOptions are optional - pass nil if you don't need targeting parameters
        // The delegate will receive onAdLoaded() or onAdFailedToLoad() callbacks
        interstitialAd?.load(requestOptions: prepareRequestOptions())
    }
    
    deinit {
        // Step 7: Clean up the ad instance when the view controller is deallocated
        // Setting interstitialAd to nil releases the ad instance and prevents memory leaks
        interstitialAd = nil
    }
}

extension InterstitialViewController: StoryboardInstantiable {}

// MARK: - InterstitialAdDelegate
extension InterstitialViewController: InterstitialAdDelegate {
    
    /// Called when the interstitial ad has successfully loaded and is ready to be displayed
    /// - Parameter ad: The InterstitialAd instance that loaded successfully
    /// - Note: The ad is now cached and ready. Call show() when appropriate for your UX
    func onAdLoaded(_ ad: BlueStackSDK.InterstitialAd) {
        Logger.debug("Interstitial ad loaded")
        DispatchQueue.main.async {
            self.showInterstitialButton.isEnabled = true
        }
    }
    
    /// Called when the interstitial ad failed to load
    /// - Parameters:
    ///   - ad: The InterstitialAd instance that failed to load
    ///   - error: The error describing why the ad failed to load
    /// - Note: Do NOT retry loading immediately - implement exponential backoff if retrying
    func onAdFailedToLoad(_ ad: BlueStackSDK.InterstitialAd, _ error: any Error) {
        Logger.error("Failed to load interstitial ad with error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.loadInterstitialButton.isEnabled = true
        }
    }
}

// MARK: - FullScreenDelegate
extension InterstitialViewController: FullScreenDelegate {
    
    /// Called when the interstitial ad is successfully displayed on screen
    /// - Parameter ad: The FullScreenDisplayableAd that was displayed
    /// - Note: The ad is now visible to the user
    func onAdDisplayed(_ ad: any FullScreenDisplayableAd) {
        Logger.debug("Interstitial ad displayed")
    }
    
    /// Called when the interstitial ad failed to display after being loaded
    /// - Parameters:
    ///   - ad: The FullScreenDisplayableAd that failed to display
    ///   - error: The error describing why the ad failed to display
    /// - Note: You should load a new ad since this one is now unusable
    func onAdFailedToDisplay(_ ad: any FullScreenDisplayableAd, _ error: any Error) {
        Logger.error("Failed to display interstitial ad with error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.loadInterstitialButton.isEnabled = true
            self.showInterstitialButton.isEnabled = false
        }
    }
    
    /// Called when the user clicks/taps on the interstitial ad
    /// - Parameter ad: The FullScreenDisplayableAd that was clicked
    /// - Note: The user will be taken to the advertiser's destination (App Store, website, etc.)
    func onAdClicked(_ ad: any FullScreenDisplayableAd) {
        Logger.debug("Interstitial ad clicked.")
    }
    
    /// Called when the user dismisses the interstitial ad (closes it)
    /// - Parameter ad: The FullScreenDisplayableAd that was dismissed
    /// - Note: Resume your app's normal flow - the ad is now closed
    func onAdDismissed(_ ad: any FullScreenDisplayableAd) {
        Logger.debug("Interstitial ad dismissed")
        DispatchQueue.main.async {
            self.loadInterstitialButton.isEnabled = true
            self.showInterstitialButton.isEnabled = false
        }
    }
}

// MARK: - UITableViewDataSource
extension InterstitialViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension InterstitialViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
