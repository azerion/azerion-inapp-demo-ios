import Foundation

protocol InlineAdViewModel: AdViewModel, ListItemViewModel {
    func stopRefresh()
    func startRefresh()
}
