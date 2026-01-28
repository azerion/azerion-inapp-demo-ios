
import UIKit

class PlaceholderTableViewCell: ListItemTableViewCell {

    private weak var currentView: UIView?
    private let defaultPlaceholderHeight = 150.0
    
    override func configure(_ viewModel: ListItemViewModel) {
        // Remove previous view if any
        currentView?.removeFromSuperview()
        currentView = nil
        
        // Get the view from the view model
        guard let view = viewModel.getView() else { return }
        
        currentView = view
        
        // Add view to cell content
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: defaultPlaceholderHeight)
        ])
        
        contentView.layoutIfNeeded()
    }
    
}
