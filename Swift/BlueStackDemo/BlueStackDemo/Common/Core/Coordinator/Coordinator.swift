import UIKit

protocol Coordinator {
    
    var childCoordinator: Coordinator? { get set }
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    
    func start() -> UIViewController?
    func finish()
}

extension Coordinator {
    
    func finish() {
        finishDelegate?.didFinish(childCoordinator: self)
    }
}

protocol CoordinatorFinishDelegate: AnyObject {
    func didFinish(childCoordinator: Coordinator)
}
