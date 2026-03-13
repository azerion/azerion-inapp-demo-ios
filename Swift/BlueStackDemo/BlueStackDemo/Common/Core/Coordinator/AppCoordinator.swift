import UIKit

class AppCoordinator: Coordinator {
    
    var childCoordinator: (any Coordinator)?
    
    weak var finishDelegate: (any CoordinatorFinishDelegate)?
    
    private(set) var isSplashCompleted = false
    private weak var navigationController: UINavigationController?
    private var coordinatorDependency: AppCoordinatorDependency
    
    init(coordinatorDependency: AppCoordinatorDependency,
         navigationController: UINavigationController) {
        self.coordinatorDependency = coordinatorDependency
        self.navigationController = navigationController
    }
    
    convenience init(navigationController: UINavigationController) {
        let coordinatorDependency = AppCoordinatorDependency()
        self.init(coordinatorDependency: coordinatorDependency, navigationController: navigationController)
    }
    
    func start() -> UIViewController? {
        let viewwController = self.coordinatorDependency.makeSplashViewController(onInitialize: onInitializationComplete)
        self.navigationController?.setViewControllers([viewwController], animated: true)
        return self.navigationController
    }
    
    private func onInitializationComplete() {
        showMainFlow()
    }
    
    func showMainFlow() {
        isSplashCompleted = true
        self.childCoordinator = coordinatorDependency.makeMenuCoordinator()
        guard let viewController = self.childCoordinator?.start() else { return }
        self.navigationController?.setViewControllers([viewController], animated: true)
    }
}
