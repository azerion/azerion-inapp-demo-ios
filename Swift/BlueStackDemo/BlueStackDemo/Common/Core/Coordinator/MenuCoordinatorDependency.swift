import UIKit

protocol MenuCoordinatorDependency {
    func makeMenuContainerViewController(delegate: MenuContainerViewControllerDelegate) -> UIViewController
    func makeViewController(for route: AppRoute) -> UIViewController
}

class DefaultMenuCoordinatorDependency: MenuCoordinatorDependency {
    
    func makeMenuContainerViewController(delegate: MenuContainerViewControllerDelegate) -> UIViewController {
        let homeViewController = makeViewController(for: .home)
        let menuViewController = makeMenuViewController()
        let menuContainerViewController = MenuContainerViewController.instantiateFromStoryboard()
        menuContainerViewController.configure(contentViewController: homeViewController, menuViewController: menuViewController)
        menuContainerViewController.delegate = delegate
        return menuContainerViewController
    }
    
    func makeViewController(for route: AppRoute) -> UIViewController {
        switch route {
        case .home:
            return HomeViewController.instantiateFromStoryboard()
        case .interstitial:
            return InterstitialViewController.instantiateFromStoryboard()
        case .mrec:
            return MRECViewController.instantiateFromStoryboard()
        case .reward:
            return RewardedVideoViewController.instantiateFromStoryboard()
        }
    }
    
    private func makeMenuViewController() -> MenuViewController {
        return MenuViewController.instantiateFromStoryboard()
    }
}
