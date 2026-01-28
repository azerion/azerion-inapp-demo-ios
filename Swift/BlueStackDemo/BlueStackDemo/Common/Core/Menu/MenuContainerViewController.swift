import UIKit

protocol MenuContainerViewControllerDelegate: AnyObject {
    func menuContainerViewController(_ controller: MenuContainerViewController, didSelectRoute route: AppRoute)
}

class MenuContainerViewController: StickyBannerViewController {
    
    weak var delegate: MenuContainerViewControllerDelegate?
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let menuWidth: CGFloat = 280
    private let animationDuration: TimeInterval = 0.3
    private let navigationBarHeight: CGFloat = 90
    
    private var isMenuOpen = false
    var menuViewController: MenuViewController!
    var contentViewController: UIViewController!
    
    private var menuLeadingConstraint: NSLayoutConstraint!
    private var contentLeadingConstraint: NSLayoutConstraint!
    private var contentTrailingConstraint: NSLayoutConstraint!
    private var contentBottomConstraint: NSLayoutConstraint!
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(contentViewController: UIViewController, menuViewController: MenuViewController) {
        self.contentViewController = contentViewController
        self.menuViewController = menuViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        addChild(menuViewController)
        view.addSubview(menuViewController.view)
        menuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        menuViewController.didMove(toParent: self)
        menuViewController.delegate = self
        
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.didMove(toParent: self)
        
        view.insertSubview(overlayView, belowSubview: contentViewController.view)
        overlayView.isUserInteractionEnabled = false
        
        menuLeadingConstraint = menuViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -menuWidth)
        contentLeadingConstraint = contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        contentTrailingConstraint = contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        contentBottomConstraint = contentViewController.view.bottomAnchor.constraint(equalTo: bannerView.topAnchor)
        
        NSLayoutConstraint.activate([
            menuLeadingConstraint,
            menuViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            menuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuViewController.view.widthAnchor.constraint(equalToConstant: menuWidth),
            
            contentLeadingConstraint,
            contentTrailingConstraint,
            contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationBarHeight),
            contentBottomConstraint,
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        updateNavigationTitle()
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        toggleMenu()
    }
    
    private func updateNavigationTitle() {
        if contentViewController is HomeViewController {
            titleLabel.text = AppRoute.home.title
        } else if contentViewController is InterstitialViewController {
            titleLabel.text = AppRoute.interstitial.title
        } else if contentViewController is MRECViewController {
            titleLabel.text = AppRoute.mrec.title
        } else if contentViewController is RewardedVideoViewController {
            titleLabel.text = AppRoute.reward.title
        } else {
            titleLabel.text = ""
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOverlayViewTap))
        overlayView.addGestureRecognizer(tapGesture)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        contentViewController.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        contentViewController.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc private func handleOverlayViewTap() {
        if isMenuOpen {
            closeMenu()
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right && !isMenuOpen {
            openMenu()
        } else if gesture.direction == .left && isMenuOpen {
            closeMenu()
        }
    }
    
    func toggleMenu() {
        if isMenuOpen {
            closeMenu()
        } else {
            openMenu()
        }
    }
    
    func switchContent(to newContentViewController: UIViewController) {
        
        if isMenuOpen {
            closeMenu()
        }
        
        contentViewController.willMove(toParent: nil)
        contentViewController.view.removeFromSuperview()
        contentViewController.removeFromParent()
        
        contentViewController = newContentViewController
        addChild(contentViewController)
        view.insertSubview(contentViewController.view, belowSubview: navigationBarView)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.didMove(toParent: self)
        
        contentLeadingConstraint.isActive = false
        contentLeadingConstraint = contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        contentTrailingConstraint.isActive = false
        contentTrailingConstraint = contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        contentBottomConstraint.isActive = false
        contentBottomConstraint = contentViewController.view.bottomAnchor.constraint(equalTo: bannerView.topAnchor)
        
        NSLayoutConstraint.activate([
            contentLeadingConstraint,
            contentTrailingConstraint,
            contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationBarHeight),
            contentBottomConstraint
        ])
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        contentViewController.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        contentViewController.view.addGestureRecognizer(swipeLeft)
        
        updateNavigationTitle()
    }
    
    func openMenu() {
        guard !isMenuOpen else { return }
        
        isMenuOpen = true
        
        view.bringSubviewToFront(menuViewController.view)
        view.bringSubviewToFront(bannerView)
        
        contentViewController.view.isUserInteractionEnabled = false
        overlayView.isUserInteractionEnabled = true
        
        menuLeadingConstraint.constant = 0
        contentLeadingConstraint.constant = menuWidth
        contentTrailingConstraint.constant = menuWidth
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut) {
            self.overlayView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func closeMenu() {
        guard isMenuOpen else { return }
        
        isMenuOpen = false
        
        menuLeadingConstraint.constant = -menuWidth
        contentLeadingConstraint.constant = 0
        contentTrailingConstraint.constant = 0

        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.overlayView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.contentViewController.view.isUserInteractionEnabled = true
            self.overlayView.isUserInteractionEnabled = false
        })
    }
}

extension MenuContainerViewController: StoryboardInstantiable {}

extension MenuContainerViewController: MenuViewControllerDelegate {
    func menuViewController(_ menuViewController: MenuViewController, didSelectMenuItem item: AppRoute) {
        delegate?.menuContainerViewController(self, didSelectRoute: item)
    }
}

