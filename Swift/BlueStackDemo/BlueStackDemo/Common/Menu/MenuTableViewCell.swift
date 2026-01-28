import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        selectedBackgroundView = selectionView
    }
    
    func configure(with menuItem: MenuItem) {
        titleLabel.text = menuItem.title
        iconImageView.image = menuItem.icon
    }
}
