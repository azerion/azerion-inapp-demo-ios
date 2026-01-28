import UIKit
import BlueStackSDK

class RewardedVideoViewController: UIViewController {
    
    @IBOutlet weak var loadRewardedAdButton: GradientButton!
    @IBOutlet weak var showRewardedButton: GradientButton!
    @IBOutlet weak var tableView: UITableView!
    
    var rewardedAd: RewardedAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showRewardedButton.isEnabled = false
    }
    
    @IBAction func loadRewardedAdButtonPressed(_ sender: Any) {
        initializeRewardedAd()
        loadRewardedAd()
        self.loadRewardedAdButton.isEnabled = false
        self.showRewardedButton.isEnabled = false
    }
    
    @IBAction func showRewardedAdButtonPressed(_ sender: Any) {
        // Step 6: Check if the ad is ready and show it
        // Ensure if the ad is ready to be displayed using isReady() before calling show()
        // The show() method presents the full-screen rewarded ad
        // The FullScreenDelegate callbacks will be triggered during the ad lifecycle
        if rewardedAd?.isReady ?? false {
            rewardedAd?.show(fromRootViewController: self)
        } else {
            Logger.warning("Rewarded ad is not ready to be shown")
        }
    }
    
    private func initializeRewardedAd() {
        // Clean up any existing rewarded ad instance before creating a new one
        if rewardedAd != nil {
            rewardedAd = nil
        }
        
        // Step 1: Create a RewardedAd instance with your placement ID
        // The placement ID identifies the ad unit in the BlueStack dashboard
        rewardedAd = RewardedAd(placementID: Constants.Placements.rewarded)
        
        // Step 2: Set the RewardedAdDelegate to receive ad lifecycle callbacks
        // This delegate handles onAdLoaded, onAdFailedToLoad, and onRewardEarned events
        rewardedAd?.delegate = self
        
        // Step 3: Set the FullScreenDelegate to receive display-related callbacks
        // This delegate handles onAdDisplayed, onAdFailedToDisplay, onAdClicked, and onAdDismissed events
        rewardedAd?.fullScreenDelegate = self
        
        // Step 4: Set the view controller
        // This is required for the SDK to properly display the full-screen content on click
        rewardedAd?.viewController = self
    }
    
    private func loadRewardedAd() {
        // Step 5: Load the rewarded ad with optional RequestOptions
        // The load() method initiates an ad request to the ad server
        // RequestOptions are optional - pass nil if you don't need targeting parameters
        // The delegate will receive onAdLoaded() or onAdFailedToLoad() callbacks
        rewardedAd?.load(requestOptions: nil)
    }
    
    deinit {
        // Step 7: Clean up the ad instance when the view controller is deallocated
        // Setting rewardedAd to nil releases the ad instance and prevents memory leaks
        rewardedAd = nil
    }
}

extension RewardedVideoViewController: StoryboardInstantiable {}

// MARK: - RewardedAdDelegate
extension RewardedVideoViewController: RewardedAdDelegate {
    
    /// Called when the rewarded ad has successfully loaded and is ready to be displayed
    /// - Parameter ad: The RewardedAd instance that loaded successfully
    /// - Note: The ad is now cached and ready. Call show() when appropriate for your UX
    func onAdLoaded(_ ad: BlueStackSDK.RewardedAd) {
        Logger.debug("Rewarded ad loaded")
        DispatchQueue.main.async {
            self.showRewardedButton.isEnabled = true
        }
    }
    
    /// Called when the rewarded ad failed to load
    /// - Parameters:
    ///   - ad: The RewardedAd instance that failed to load
    ///   - error: The error describing why the ad failed to load
    /// - Note: Do NOT retry loading immediately - implement exponential backoff if retrying
    func onAdFailedToLoad(_ ad: BlueStackSDK.RewardedAd, _ error: any Error) {
        Logger.error("Failed to load rewarded ad with error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.loadRewardedAdButton.isEnabled = true
        }
    }
    
    /// Called when the user has earned a reward by watching the rewarded ad
    /// - Parameters:
    ///   - ad: The RewardedAd instance that triggered the reward
    ///   - reward: The Reward object containing reward details (amount, currency, etc.)
    /// - Note: Grant the reward to the user in your app (coins, lives, premium content, etc.)
    func onRewardEarned(_ ad: BlueStackSDK.RewardedAd, _ reward: BlueStackSDK.Reward?) {
        if let reward = reward {
            Logger.info("User earned reward - Amount: \(String(describing: reward.amount?.floatValue)), Currency: \(String(describing: reward.currency))")
        } else {
            Logger.warning("Reward earned but reward object is nil")
        }
    }
}

// MARK: - FullScreenDelegate
extension RewardedVideoViewController: FullScreenDelegate {
    
    /// Called when the rewarded ad is successfully displayed on screen
    /// - Parameter ad: The FullScreenDisplayableAd that was displayed
    /// - Note: The ad is now visible to the user
    func onAdDisplayed(_ ad: any FullScreenDisplayableAd) {
        Logger.debug("Rewarded ad displayed")
    }
    
    /// Called when the rewarded ad failed to display after being loaded
    /// - Parameters:
    ///   - ad: The FullScreenDisplayableAd that failed to display
    ///   - error: The error describing why the ad failed to display
    /// - Note: You should load a new ad since this one is now unusable
    func onAdFailedToDisplay(_ ad: any FullScreenDisplayableAd, _ error: any Error) {
        Logger.error("Failed to display rewarded ad with error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.loadRewardedAdButton.isEnabled = true
            self.showRewardedButton.isEnabled = false
        }
    }
    
    /// Called when the user clicks/taps on the rewarded ad
    /// - Parameter ad: The FullScreenDisplayableAd that was clicked
    /// - Note: The user will be taken to the advertiser's destination (App Store, website, etc.)
    func onAdClicked(_ ad: any FullScreenDisplayableAd) {
        Logger.debug("Rewarded ad clicked")
    }
    
    /// Called when the user dismisses the rewarded ad (closes it)
    /// - Parameter ad: The FullScreenDisplayableAd that was dismissed
    /// - Note: Resume your app's normal flow - the ad is now closed
    func onAdDismissed(_ ad: any FullScreenDisplayableAd) {
        Logger.debug("Rewarded ad dismissed")
        DispatchQueue.main.async {
            self.loadRewardedAdButton.isEnabled = true
            self.showRewardedButton.isEnabled = false
        }
    }
}

// MARK: - UITableViewDataSource
extension RewardedVideoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RewardedVideoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
