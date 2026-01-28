
import UIKit

extension UIView {
    
    class func identifier() -> String {
        let id = String(describing: self) + "ID"
        return id
    }
    
}
