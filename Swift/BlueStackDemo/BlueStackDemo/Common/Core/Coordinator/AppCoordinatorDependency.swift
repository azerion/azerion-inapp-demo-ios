import UIKit

class AppCoordinatorDependency {
    
    func makeSplashViewController(onInitialize:(() -> Void)?) -> UIViewController {
        let splashViewController = SplashViewController.instantiateFromStoryboard()
        splashViewController.onInitializationComplete = onInitialize
        return splashViewController
    }
    
    func makeMenuCoordinator() -> Coordinator {
        return MenuCoordinator()
    }
    
}
