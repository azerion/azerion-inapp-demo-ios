import Foundation

@objc public final class CMPManagerFactory: NSObject {
    
    @objc public func createCMPManager() -> CMPManager {
        return DefaultCMPManager(userDefaults: UserDefaults.standard)
    }
}
