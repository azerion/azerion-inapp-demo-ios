import Foundation

enum AppRoute {
    case home
    case interstitial
    case mrec
    case reward
}

extension AppRoute {
    var title: String {
        switch self {
        case .home:
            return "Banner"
        case .interstitial:
            return "Interstitial"
        case .mrec:
            return "MREC"
        case .reward:
            return "Reward"
        }
    }
}
