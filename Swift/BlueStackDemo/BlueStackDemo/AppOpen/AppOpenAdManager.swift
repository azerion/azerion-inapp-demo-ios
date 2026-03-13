//
//  AppOpenAdManager.swift
//  BlueStackDemo
//
//  Created by shadman on 26/2/26.
//

import Foundation
import BlueStackSDK

protocol AppOpenAdManagerDelegate: AnyObject {
    func appOpenAdDidComplete(_ appOpenAdManager: AppOpenAdManager)
}

class AppOpenAdManager: NSObject {
    
    static let shared = AppOpenAdManager()
    
    var appOpenAd: AppOpenAd?
    
    weak var appOpenAdManagerDelegate: AppOpenAdManagerDelegate?
    /// App Open ad is loading.
    var isLoadingAd = false
    /// App Open ad is showing.
    var isShowingAd = false
    /// App Open ad load time to discard expired ad.
    var loadTime: Date?
    /// Timeout interval of app open ad expiration (4 hours)
    let timeoutInterval: TimeInterval = 4 * 3_600
    
    private func hasNotExpired(within: TimeInterval) -> Bool {
        // Check if app open ad was loaded more than n hours ago.
        if let loadTime = loadTime {
            return Date().timeIntervalSince(loadTime) < timeoutInterval
        }
        return false
    }
    
    private func isAppOpenAdAvailableToShow() -> Bool {
        // Check if app open ad exists and not expired.
        return appOpenAd != nil && hasNotExpired(within: timeoutInterval)
    }
    
    func loadAppOpenAd() {
        if isLoadingAd || isAppOpenAdAvailableToShow() {
            return
        }
        
        let placementID = Constants.Placements.appOpen
        loadAppOpenAd(placementID: placementID)
    }
    
    /// Step 6: Show the app open ad if one is available
    /// Checks if the ad is already showing or if a valid ad is cached before attempting to display.
    /// If no ad is available, it notifies the delegate and triggers a new load.
    /// The show() method presents the full-screen app open ad from the root view controller.
    func showAppOpenAdIfAvailable() {
        if isShowingAd {
            return print("App open ad is already showing.")
        }
        
        if !isAppOpenAdAvailableToShow() {
            print("App open ad is not ready yet.")
            
            appOpenAdManagerDelegate?.appOpenAdDidComplete(self)
            
            loadAppOpenAd()
            
            return
        }
        
        DispatchQueue.main.async {
            if self.appOpenAd?.isReady ?? false {
                self.appOpenAd?.show(fromRootViewController: nil)
                self.isShowingAd = true
            }
        }
    }
    
    private func loadAppOpenAd(placementID: String) {
        isLoadingAd = true
        
        // Clean up any existing app open ad instance before creating a new one
        if appOpenAd != nil {
            appOpenAd = nil
        }
        
        // Step 1: Create an AppOpenAd instance with your placement ID
        // The placement ID identifies the ad unit in the BlueStack dashboard
        appOpenAd = AppOpenAd(placementID: placementID)
        
        // Step 2: Set the AppOpenAdDelegate to receive ad lifecycle callbacks
        // This delegate handles onAdLoaded and onAdFailedToLoad events
        appOpenAd?.delegate = self
        
        // Step 3: Set the FullScreenDelegate to receive display-related callbacks
        // This delegate handles onAdDisplayed, onAdFailedToDisplay, onAdClicked, and onAdDismissed events
        appOpenAd?.fullScreenDelegate = self
        
        // Step 4: Set the view controller to nil for app open ads
        // App open ads are presented from the root view controller automatically
        appOpenAd?.viewController = nil
        
        // Step 5: Load the app open ad with optional RequestOptions
        // The load() method initiates an ad request to the ad server
        // RequestOptions are optional - pass nil if you don't need targeting parameters
        // The delegate will receive onAdLoaded() or onAdFailedToLoad() callbacks
        appOpenAd?.load(requestOptions: prepareRequestOptions())
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
}

// MARK: - AppOpenAdDelegate
extension AppOpenAdManager: AppOpenAdDelegate {
    
    /// Called when the app open ad has successfully loaded and is ready to be displayed
    /// - Parameter ad: The AppOpenAd instance that loaded successfully
    /// - Note: The ad is now cached and ready. It will be shown on the next foreground transition
    func onAdLoaded(_ ad: BlueStackSDK.AppOpenAd) {
        print("AppOpenAd ad loaded")
        isLoadingAd = false
        loadTime = Date()
    }
    
    /// Called when the app open ad failed to load
    /// - Parameters:
    ///   - ad: The AppOpenAd instance that failed to load
    ///   - error: The error describing why the ad failed to load
    /// - Note: The ad instance and load time are cleared so a fresh load can be attempted later
    func onAdFailedToLoad(_ ad: BlueStackSDK.AppOpenAd, _ error: any Error) {
        print("Failed to load app open ad with error: \(error.localizedDescription)")
        isLoadingAd = false
        appOpenAd = nil
        loadTime = nil
    }
}

// MARK: - FullScreenDelegate
extension AppOpenAdManager: FullScreenDelegate {
    
    /// Called when the app open ad is successfully displayed on screen
    /// - Parameter ad: The FullScreenDisplayableAd that was displayed
    /// - Note: The ad is now visible to the user
    func onAdDisplayed(_ ad: any FullScreenDisplayableAd) {
        print("AppOpenAd ad displayed")
    }
    
    /// Called when the app open ad failed to display after being loaded
    /// - Parameters:
    ///   - ad: The FullScreenDisplayableAd that failed to display
    ///   - error: The error describing why the ad failed to display
    /// - Note: The ad instance is cleared, the delegate is notified, and a new ad load is triggered
    func onAdFailedToDisplay(_ ad: any FullScreenDisplayableAd, _ error: any Error) {
        print("Failed to display app open ad with error: \(error.localizedDescription)")
        appOpenAd = nil
        isShowingAd = false
        appOpenAdManagerDelegate?.appOpenAdDidComplete(self)
        loadAppOpenAd()
    }
    
    /// Called when the user clicks/taps on the app open ad
    /// - Parameter ad: The FullScreenDisplayableAd that was clicked
    /// - Note: The user will be taken to the advertiser's destination (App Store, website, etc.)
    func onAdClicked(_ ad: any FullScreenDisplayableAd) {
        print("AppOpenAd ad clicked.")
    }
    
    /// Called when the user dismisses the app open ad (closes it)
    /// - Parameter ad: The FullScreenDisplayableAd that was dismissed
    /// - Note: The ad instance is cleared, the delegate is notified, and a new ad is preloaded for the next opportunity
    func onAdDismissed(_ ad: any FullScreenDisplayableAd) {
        print("AppOpenAd ad dismissed")
        appOpenAd = nil
        isShowingAd = false
        appOpenAdManagerDelegate?.appOpenAdDidComplete(self)
        loadAppOpenAd()
    }
}
