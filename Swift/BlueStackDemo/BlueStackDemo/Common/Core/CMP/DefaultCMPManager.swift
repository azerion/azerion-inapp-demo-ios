import Foundation
import UIKit

struct IABConstants {
    static let IABTCF_TCString = "IABTCF_TCString"
    static let IABTCF_PurposeConsents = "IABTCF_PurposeConsents"
    static let IABTCF_gdprApplies = "IABTCF_gdprApplies"
    static let IABTCF_SpecialFeaturesOptIns = "IABTCF_SpecialFeaturesOptIns"
    static let IABTCF_PublisherRestrictions1 = "IABTCF_PublisherRestrictions1"
    static let IABTCF_PublisherRestrictions2 = "IABTCF_PublisherRestrictions2"
}
@objc public class DefaultCMPManager: NSObject, CMPManager {

    private let yesConsent = "CP3CBVhP3CBVhBaIOBFRATEsAP_gAH_gAAqIg1NX_H__bX9v-Xr36ft0eY1f99j77sQxBhfJs-4FyLvW_JwX32EyNE26tqYKmRIEu3ZBIQFtHJnURVihaogVrzHsYkGcgTNKJ-BkgHMRe2dYCF5vmYtj-QKZ5_p_d3f52T_9_dv-3dzzz9Vnv3e9fudlcIida59tH_n_bRKb-7Ie9_7-_4v09N_rk2_eTVv_9evv71-u_t____9_9__-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAEQamr_j__tr-3_L179P26PMav--x992IYgwvk2fcC5F3rfk4L77CZGibdW1MFTIkCXbsgkIC2jkzqIqxQtUQK15j2MSDOQJmlE_AyQDmIvbOsBC83zMWx_IFM8_0_u7v87J_-_u3_bu555-qz37vev3OyuEROtc-2j_z_tolN_dkPe_9_f8X6em_1ybfvJq3_-vX396_Xf2____-_-___AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAACAA"
    private let noConsent = "CP20-YAP20-YAAHABAENAeEgAAAAAAAAAAAAAAAAAAAA"
    private let yesPurposeConsent = "1111111111"
    private let noPurposeConsent = "0000000000"
    private var alertController: UIAlertController?
    private var delegate: CMPManagerDelegate?
    private var userDefaults: UserDefaults
    
    public var configuration: CMPConfig?
    
    public var hasConsent: Bool {
        return self.userDefaults.object(forKey: IABConstants.IABTCF_TCString) != nil
    }
    
    init(userDefaults: UserDefaults, configuration: CMPConfig? = nil) {
        self.configuration = configuration
        self.userDefaults = userDefaults
    }
    
    public func start(with delegate: CMPManagerDelegate?) {
        self.delegate = delegate
        self.alertController = UIAlertController(title: "Consent Manager", message: "We would like to read out your device identifier for targetted Ads", preferredStyle: .alert)
        self.alertController?.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.alertController?.dismiss(animated: true, completion: {
                self.acceptAllIABConsent()
                self.delegate?.onConsentStringDidChange(consentManager: self, consentString: self.yesConsent)
            })
        }))
        
        self.alertController?.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.alertController?.dismiss(animated: true, completion: {
                self.refuseAllIABConsent()
                self.delegate?.onConsentStringDidChange(consentManager: self, consentString: self.noConsent)
            })
            
        }))
        guard self.userDefaults.value(forKey: IABConstants.IABTCF_TCString) == nil else {
            return
        }
        self.delegate?.onRequestsToShowConsentTool(consentManager: self)
    }
    
    public func showConsent(from viewController: UIViewController) {
        if let alertController = self.alertController {
            viewController.present(alertController, animated: true)
        }
    }
    public var gdprApplies: Bool {
        get {
            return self.userDefaults.integer(forKey: IABConstants.IABTCF_gdprApplies) == 1
        }
        set(newValue) {
            self.userDefaults.set(newValue ? 1 : 0, forKey: IABConstants.IABTCF_gdprApplies)
        }
    }
    public func acceptAllIABConsent() {
        self.userDefaults.set(self.yesConsent, forKey: IABConstants.IABTCF_TCString)
        self.userDefaults.set(self.yesPurposeConsent, forKey: IABConstants.IABTCF_PurposeConsents)
        self.userDefaults.set("11", forKey: IABConstants.IABTCF_SpecialFeaturesOptIns)
        self.userDefaults.set(            "_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________1________________________________________________________________________________________________1_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________1", forKey: IABConstants.IABTCF_PublisherRestrictions1)
        self.userDefaults.set(            "_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________1________________________________________________________________________________________________1_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________1", forKey: IABConstants.IABTCF_PublisherRestrictions2)
        self.userDefaults.set(1, forKey: IABConstants.IABTCF_gdprApplies)

    }
    public func refuseAllIABConsent() {
        self.userDefaults.set(self.noConsent, forKey: IABConstants.IABTCF_TCString)
        self.userDefaults.set(self.noPurposeConsent, forKey: IABConstants.IABTCF_PurposeConsents)
        self.userDefaults.removeObject(forKey: IABConstants.IABTCF_SpecialFeaturesOptIns)
        self.userDefaults.removeObject(forKey: IABConstants.IABTCF_PublisherRestrictions1)
        self.userDefaults.removeObject(forKey: IABConstants.IABTCF_PublisherRestrictions2)
        self.userDefaults.set(0, forKey: IABConstants.IABTCF_gdprApplies)
    }
}
