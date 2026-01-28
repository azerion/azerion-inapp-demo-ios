import UIKit

class DefaultPlaceholderViewModel: PlaceholderViewModel {
    func getView() -> UIView? {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "content_left")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }
}
