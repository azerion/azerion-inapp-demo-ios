import UIKit

/// A custom UIButton subclass that automatically configures gradient background for normal state
/// and grey background for disabled state. Can be used directly in storyboards via @IBDesignable.
@IBDesignable
class GradientButton: UIButton {
    
    /// The name of the gradient image asset to use for the normal state
    /// Default is "buttonGradient"
    @IBInspectable var gradientImageName: String = "buttonGradient" {
        didSet {
            configureAppearance()
        }
    }
    
    /// The color to use for the disabled state background
    /// Default is dark grey
    @IBInspectable var disabledBackgroundColor: UIColor = UIColor.darkGray {
        didSet {
            configureAppearance()
        }
    }
    
    /// The text color for normal state
    /// Default is white
    @IBInspectable var normalTextColor: UIColor = .white {
        didSet {
            setTitleColor(normalTextColor, for: .normal)
        }
    }
    
    /// The text color for disabled state
    /// Default is white
    @IBInspectable var disabledTextColor: UIColor = .white {
        didSet {
            setTitleColor(disabledTextColor, for: .disabled)
        }
    }
    
    /// The corner radius for the button
    /// Default is 8.0
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAppearance()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureAppearance()
    }

    private func configureAppearance() {
        // Set gradient background for normal state
        setBackgroundImage(UIImage(named: gradientImageName), for: .normal)
        
        // Create and set solid color background for disabled state
        let disabledImage = createSolidColorImage(color: disabledBackgroundColor, size: CGSize(width: 1, height: 1))
        setBackgroundImage(disabledImage, for: .disabled)
        
        // Set text colors
        setTitleColor(normalTextColor, for: .normal)
        setTitleColor(disabledTextColor, for: .disabled)
        
        // Apply corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }
    
    /// Creates a solid color image programmatically
    /// - Parameters:
    ///   - color: The color to fill the image with
    ///   - size: The size of the image (typically 1x1 for backgrounds)
    /// - Returns: A UIImage filled with the specified color
    private func createSolidColorImage(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
