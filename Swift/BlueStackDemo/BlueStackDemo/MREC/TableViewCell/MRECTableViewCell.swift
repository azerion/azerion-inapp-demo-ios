
import UIKit

/// Custom table view cell for displaying MREC (Medium Rectangle) banner ads
/// This cell is designed to host inline ad views within a table view
/// It handles dynamic view loading, layout, and cleanup
class MRECTableViewCell: ListItemTableViewCell {

    /// Weak reference to the currently displayed view
    /// Using weak reference prevents retain cycles and allows proper cleanup
    private weak var currentView: UIView?
    
    private let padding = 5.0
  
    /// Configures the cell with a view model
    /// This method handles ad loading, view cleanup, and layout setup
    /// - Parameter viewModel: The view model providing the content to display
    override func configure(_ viewModel: any ListItemViewModel) {
        
        // Step 1: Check if this is an ad view model and load the ad if needed
        // If the ad hasn't been loaded yet, trigger the load process
        // This ensures ads are loaded lazily when the cell becomes visible
        if let adViewModel = viewModel as? InlineAdViewModel,
           adViewModel.isAdLoaded() == false {
            adViewModel.loadAd()
        }
        
        // Step 2: Clean up any previously displayed view
        // Remove the old view from the cell's content view hierarchy
        // This prevents view stacking and memory leaks when cells are reused
        currentView?.removeFromSuperview()
        currentView = nil
        
        // Step 3: Get the view from the view model
        // The view model provides the actual UIView to display (e.g., BannerView)
        // If no view is available (e.g., ad still loading), exit early
        guard let view = viewModel.getView() else { return }
        
        // Step 4: Store reference to the new view
        currentView = view
        
        // Step 5: Add the view to the cell's content view
        // Disable autoresizing mask translation to use Auto Layout constraints
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        // Step 6: Set up Auto Layout constraints
        // Center the ad horizontally and add vertical padding
        // The ad view determines its own height based on the ad size
        NSLayoutConstraint.activate([
            // Center the ad horizontally in the cell
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Add padding from the top
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            
            // Add padding from the bottom
            // This constraint also drives the cell's height based on the ad view's intrinsic size
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
        // Step 7: Force layout update
        // Ensures the view is properly laid out immediately
        contentView.layoutIfNeeded()
    }
    
}
