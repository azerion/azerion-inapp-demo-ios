import Foundation

protocol AdViewModel {
    func loadAd()
    func isAdLoaded() -> Bool
    func destroyAd()
    var onAdLoaded: (() -> Void)? { get set }
}
