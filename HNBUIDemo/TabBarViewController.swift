//
//  TabBarViewController.swift
//  HNBUIDemo
//
//  Created by Kenichi Fujita on 4/14/21.
//

import UIKit
import HNBUI

class TabBarViewController: TabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        viewControllers = [
            viewController(tabBarItemTitle: "Top Stories",
                           tabBarItemImage: UIImage(systemName: "list.number"),
                           backgroundColor: .blue),
            viewController(tabBarItemTitle: "Ask HN",
                           tabBarItemImage: UIImage(systemName: "questionmark.circle"),
                           backgroundColor: .brown),
            viewController(tabBarItemTitle: "Show HN",
                           tabBarItemImage: UIImage(systemName: "globe"),
                           backgroundColor: .cyan),
            viewController(tabBarItemTitle: "Search",
                           tabBarItemImage: UIImage(systemName: "magnifyingglass"),
                           backgroundColor: .darkGray),
            viewController(tabBarItemTitle: "Favorite",
                           tabBarItemImage: UIImage(systemName: "star"),
                           backgroundColor: .green)
        ]
    }

    func viewController(tabBarItemTitle: String, tabBarItemImage: UIImage?, backgroundColor: UIColor) -> UIViewController {
        let viewController = UIViewController()
        viewController.tabBarItem.title = tabBarItemTitle
        viewController.tabBarItem.image = tabBarItemImage
        viewController.view.backgroundColor = backgroundColor
        return viewController
    }

}
