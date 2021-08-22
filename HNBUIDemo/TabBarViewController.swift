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

        let topStoriesViewController = ViewController(tabBarItemTitle: "Top Stories",
                                                      tabBarItemImage: nil,
                                                      backgroundColor: .blue)
        

        viewControllers = [
            topStoriesViewController,
            viewController(tabBarItemTitle: "Ask HN",
                           tabBarItemImage: nil,
                           backgroundColor: .brown),
            viewController(tabBarItemTitle: "Show HN",
                           tabBarItemImage: nil,
                           backgroundColor: .cyan),
            viewController(tabBarItemTitle: "Search",
                           tabBarItemImage: nil,
                           backgroundColor: .darkGray),
            viewController(tabBarItemTitle: "Favorite",
                           tabBarItemImage: nil,
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
