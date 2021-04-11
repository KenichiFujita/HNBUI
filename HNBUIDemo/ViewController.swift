//
//  ViewController.swift
//  HNBUIDemo
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit
import HNBUI

class ViewController: UIViewController {

    private lazy var tabBar: TabBar = {
        let tabBar = TabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.delegate = self
        let item1 = UITabBarItem(title: "Top Story", image: UIImage(systemName: "list.number"), tag: 0)
        let item2 = UITabBarItem(title: "Ask HN", image: UIImage(systemName: "questionmark.circle"), tag: 0)
        let item3 = UITabBarItem(title: "Show HN", image: UIImage(systemName: "globe"), tag: 0)
        let item4 = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        let item5 = UITabBarItem(title: "Favorite", image: UIImage(systemName: "star"), tag: 0)
        tabBar.items = [item1, item2, item3, item4, item5]
        return tabBar
    }()

    private let demoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemBackground
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tabBar)
        view.addSubview(demoLabel)

        NSLayoutConstraint.activate( [
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            demoLabel.heightAnchor.constraint(equalToConstant: 100),
            demoLabel.widthAnchor.constraint(equalToConstant: 100),
            demoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            demoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }

}

extension ViewController: TabBarDelegate {

    func tabBar(_ tabBar: TabBar, didSelectItemAt index: Int) {
        demoLabel.text = String(index)
    }

}
