import Foundation
import UIKit
import BlueStackSDK

class HomeViewController: UIViewController {
    
    private enum BannerTab: Int, CaseIterable {
        case standard = 0
        case full = 1
        case large = 2
        case leader = 3
    }
    
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var tabIndicator: UIView!
    @IBOutlet weak var tabIndicatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tabIndicatorWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentContainer: UIView!
    
    private var pageViewController: UIPageViewController!
    private var currentTabIndex: Int = 0
    private var cachedViewControllers: [Int: UIViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        tabButtons.sort { $0.tag < $1.tag }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "embedPageViewController",
           let pageVC = segue.destination as? UIPageViewController {
            pageViewController = pageVC
            setupPageViewController()
        }
    }
    
    private func setupPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstVC = viewController(at: BannerTab.standard.rawValue) {
            pageViewController.setViewControllers(
                [firstVC],
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
        
        selectTab(at: BannerTab.standard.rawValue, animated: false)
    }
    
    @IBAction func tabButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        selectTab(at: index, animated: true)
    }
    
    private func selectTab(at index: Int, animated: Bool) {
        guard index >= 0 && index < tabButtons.count else { return }
        guard index != currentTabIndex else { return }
        
        let previousIndex = currentTabIndex
        currentTabIndex = index
        
        updateTabButtonColors()
        
        animateTabIndicator(to: index, animated: animated)
        
        navigateToPage(at: index, from: previousIndex, animated: animated)
    }
    
    private func updateTabButtonColors() {
        for (i, button) in tabButtons.enumerated() {
            if i == currentTabIndex {
                button.setTitleColor(.black, for: .normal)
            } else {
                button.setTitleColor(.systemGray, for: .normal)
            }
        }
    }
    
    private func animateTabIndicator(to index: Int, animated: Bool) {
        let selectedButton = tabButtons[index]
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseInOut],
                animations: { [weak self] in
                    self?.tabIndicatorLeadingConstraint.constant = selectedButton.frame.origin.x
                    self?.view.layoutIfNeeded()
                }
            )
        } else {
            tabIndicatorLeadingConstraint.constant = selectedButton.frame.origin.x
        }
    }
    
    private func navigateToPage(at index: Int, from previousIndex: Int, animated: Bool) {
        guard let viewController = viewController(at: index) else { return }
        
        let direction: UIPageViewController.NavigationDirection = index > previousIndex ? .forward : .reverse
        
        pageViewController.setViewControllers(
            [viewController],
            direction: direction,
            animated: animated,
            completion: nil
        )
    }
  
    private func viewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < BannerTab.allCases.count else { return nil }
        
        if let cachedVC = cachedViewControllers[index] {
            return cachedVC
        }
       
        let viewController: UIViewController
        switch BannerTab(rawValue: index) {
        case .standard:
            viewController = StandardBannerViewController.instantiateFromStoryboard()
        case .full:
            viewController = FullBannerViewController.instantiateFromStoryboard()
        case .large:
            viewController = LargeBannerViewController.instantiateFromStoryboard()
        case .leader:
            viewController = LeaderBannerViewController.instantiateFromStoryboard()
        case .none:
            return nil
        }
       
        cachedViewControllers[index] = viewController
        return viewController
    }
    
    private func index(of viewController: UIViewController) -> Int? {
        return cachedViewControllers.first(where: { $0.value === viewController })?.key
    }
}

extension HomeViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = index(of: viewController) else { return nil }
        let previousIndex = currentIndex - 1
        return self.viewController(at: previousIndex)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = index(of: viewController) else { return nil }
        let nextIndex = currentIndex + 1
        return self.viewController(at: nextIndex)
    }
}

extension HomeViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentViewController = pageViewController.viewControllers?.first,
              let newIndex = index(of: currentViewController),
              newIndex != currentTabIndex else {
            return
        }
       
        currentTabIndex = newIndex
        updateTabButtonColors()
        animateTabIndicator(to: newIndex, animated: true)
    }
}

extension HomeViewController: StoryboardInstantiable {}
