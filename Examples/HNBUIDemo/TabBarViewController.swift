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

        let topStoriesViewController = ViewController(tabBarItemTitle: "top",
                                                      tabBarItemImage: nil,
                                                      backgroundColor: .blue)
        let newStoriesViewController = ViewController(tabBarItemTitle: "new",
                                                        tabBarItemImage: nil,
                                                        backgroundColor: .brown)
        let askStoriesViewController = ViewController(tabBarItemTitle: "ask",
                                                         tabBarItemImage: nil,
                                                         backgroundColor: .cyan)
        let showStoriesViewController = ViewController(tabBarItemTitle: "show",
                                                         tabBarItemImage: nil,
                                                         backgroundColor: .darkGray)
        let jobStoriesViewController = ViewController(tabBarItemTitle: "job",
                                                            tabBarItemImage: nil,
                                                            backgroundColor: .green)
        let bestStoriesViewController = ViewController(tabBarItemTitle: "best",
                                                            tabBarItemImage: nil,
                                                            backgroundColor: .orange)
        let activeStoriesViewController = ViewController(tabBarItemTitle: "acrive",
                                                            tabBarItemImage: nil,
                                                            backgroundColor: .magenta)
        viewControllers = [
            topStoriesViewController,
            newStoriesViewController,
            askStoriesViewController,
            showStoriesViewController,
            jobStoriesViewController,
            bestStoriesViewController,
            activeStoriesViewController
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
