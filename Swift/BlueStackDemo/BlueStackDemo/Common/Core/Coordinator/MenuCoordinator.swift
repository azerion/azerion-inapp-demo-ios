import UIKit

class MenuCoordinator: Coordinator {
    
    var childCoordinator: (any Coordinator)?
    
    weak var finishDelegate: (any CoordinatorFinishDelegate)?
    
    private var coordinatorDependency: MenuCoordinatorDependency
    
    init(coordinatorDependency: MenuCoordinatorDependency) {
        self.coordinatorDependency = coordinatorDependency
    }
    
    convenience init() {
        self.init(coordinatorDependency: DefaultMenuCoordinatorDependency())
    }
    
    func start() -> UIViewController? {
        let viewController = coordinatorDependency.makeMenuContainerViewController(delegate: self)
        return viewController
    }
}

extension MenuCoordinator: MenuContainerViewControllerDelegate {
    func menuContainerViewController(_ controller: MenuContainerViewController, didSelectRoute route: AppRoute) {
        
        if let currentContent = controller.contentViewController {
            switch route {
            case .home:
                if currentContent is HomeViewController {
                    controller.closeMenu()
                    return
                }
            case .interstitial:
                if currentContent is InterstitialViewController {
                    controller.closeMenu()
                    return
                }
            case .mrec:
                if currentContent is MRECViewController {
                    controller.closeMenu()
                    return
                }
            case .reward:
                if currentContent is RewardedVideoViewController {
                    controller.closeMenu()
                    return
                }
            }
        }
        
        let newContentVC = coordinatorDependency.makeViewController(for: route)
        controller.switchContent(to: newContentVC)
    }
}
