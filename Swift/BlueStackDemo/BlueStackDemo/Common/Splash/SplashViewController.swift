import Foundation
import UIKit
import AppTrackingTransparency
import BlueStackSDK

class SplashViewController: UIViewController {
    
    var onInitializationComplete: (() -> Void)?
    
    private var cmpManager: CMPManager?
    private var cmpFactory: CMPManagerFactory = CMPManagerFactory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        requestAppTracking()
    }
    
    /// Step 1: Request App Tracking Transparency (ATT) Permission
    /// App Tracking Transparency (ATT) is required by Apple for iOS 14+ to track users across apps and websites.
    /// This must be requested BEFORE initializing the BlueStack SDK to ensure proper consent handling.
    private func requestAppTracking() {
        guard #available(iOS 14, *) else {
            self.requestCMP()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    // Proceed to CMP regardless of ATT status
                    // The SDK will handle the tracking permission internally
                    self.requestCMP()
                }
            }
        }
    }
    
    /// Step 2: Request Consent Management Platform (CMP) Consent
    /// CMP handles GDPR/CCPA compliance by collecting user consent for data processing.
    /// This step is crucial for European users and privacy-conscious regions.
    /// Reference: https://developers.bluestack.app/ios/privacy
    private func requestCMP() {
        self.cmpManager = self.cmpFactory.createCMPManager()
        self.cmpManager?.start(with: self)
        
        if self.cmpManager?.hasConsent == true {
            self.startInitializingBlueStackSDK()
        }
    }
    
    /// Step 3: Initialize BlueStack SDK
    /// This method should ONLY be called after:
    /// 1. ATT permission has been requested (iOS 14+)
    /// 2. CMP consent has been obtained or CMP has failed
    private func startInitializingBlueStackSDK() {
        BlueStack.sharedInstance().setDebugMode(enabled: true)
        BlueStack.sharedInstance().initialize(appID: Constants.appID) { initializationStatus in
            for ( _ , adapterStatus) in initializationStatus.adapterStatuses {
                Logger.debug("adapter name \(adapterStatus.name) has this state \(adapterStatus.state) with Description \(String(describing: adapterStatus.statusDescription))")
            }
            DispatchQueue.main.async {
                self.onInitializationComplete?()
            }
        }
    }
}

extension SplashViewController: CMPManagerDelegate {
    func onRequestsToShowConsentTool(consentManager: CMPManager) {
        consentManager.showConsent(from: self)
    }
    
    func onConsentStringDidChange(consentManager: CMPManager, consentString: String) {
        self.startInitializingBlueStackSDK()
    }
    
    func onConsentManagerDidFail(consentManager: CMPManager, error: Error) {
        self.startInitializingBlueStackSDK()
    }
    
    func onConsentManagerRequestsToPresentPrivacyPolicy(consentManager: CMPManager, url: String) {}
}

extension SplashViewController: StoryboardInstantiable {}
