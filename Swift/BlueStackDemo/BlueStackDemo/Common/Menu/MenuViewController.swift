import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func menuViewController(_ menuViewController: MenuViewController, didSelectMenuItem item: AppRoute)
}

struct MenuItem {
    let title: String
    let icon: UIImage?
    let route: AppRoute
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MenuViewControllerDelegate?
    
    private var menuItems: [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMenuItems()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func setUpMenuItems() {
        menuItems = [
            MenuItem(title: "Banner", icon: UIImage(named: "menu_banner"), route: .home),
            MenuItem(title: "MREC", icon: UIImage(named: "menu_banner"), route: .mrec),
            MenuItem(title: "Interstitial", icon: UIImage(named: "menu_interstitial"), route: .interstitial),
            MenuItem(title: "Reward", icon: UIImage(named: "menu_rewarded_video"), route: .reward)
        ]
    }
    
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        let menuItem = menuItems[indexPath.row]
        cell.configure(with: menuItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = menuItems[indexPath.row]
        delegate?.menuViewController(self, didSelectMenuItem: selectedItem.route)
    }
}

extension MenuViewController: StoryboardInstantiable {}
