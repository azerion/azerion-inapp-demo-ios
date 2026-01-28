import Foundation
import UIKit

@objcMembers
public class CMPConfig: NSObject {
    var localConfigFilePath: String?
    var remoteConfigFilePath: String?
    var language: String?
    var providerId: String?
}

@objc public protocol CMPManagerDelegate: NSObjectProtocol {
    @objc(didRequestedToShowConsentTool:)
    func onRequestsToShowConsentTool(consentManager: CMPManager)
    
    @objc(consentManager:didChangeConsentString:)
    func onConsentStringDidChange(consentManager: CMPManager, consentString: String)
    
    @objc(consentManager:didFailedWithError:)
    func onConsentManagerDidFail(consentManager: CMPManager, error: Error)
    
    @objc(consentManager:didRequestedToPresentPrivacyPolicyUrl:)
    func onConsentManagerRequestsToPresentPrivacyPolicy(consentManager: CMPManager, url: String)
}

@objc public protocol CMPManager: NSObjectProtocol {
    @objc var gdprApplies: Bool {get set}
    @objc var configuration: CMPConfig? {get set}
    @objc var hasConsent: Bool {get}
    @objc func start(with delegate: CMPManagerDelegate?)
    @objc func showConsent(from viewController: UIViewController)
    @objc func acceptAllIABConsent()
    @objc func refuseAllIABConsent()
}
