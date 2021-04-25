//
//  TabBarController.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit

public protocol TabBarControllerDelegate: AnyObject {

    func tabBarController(_ tabBarController: TabBarController, didSelect viewController: UIViewController)
}

open class TabBarController: UIViewController {

    public weak var delegate: TabBarControllerDelegate?

    private var shouldScrollTabBar = false

    public var viewControllers: [UIViewController]? {
        didSet {
            guard let viewControllers = viewControllers else { return }
            tabBar.items = viewControllers.map { viewController in
                viewController.tabBarItem
            }
            containerScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(viewControllers.count), height: containerScrollView.bounds.height)
            viewControllers.enumerated().forEach { (index, viewController) in
                addChild(viewController)
                containerScrollView.addSubview(viewController.view)
                viewController.view.frame = containerScrollView.bounds
                viewController.view.frame.origin.x = view.bounds.width * CGFloat(index)
                viewController.didMove(toParent: self)
            }
        }
    }

    public let tabBar: TabBar = {
        let tabBar = TabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()

    private let containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    open override func loadView() {
        super.loadView()

        view.addSubview(tabBar)
        view.addSubview(containerScrollView)

        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerScrollView.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            containerScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
        containerScrollView.delegate = self
    }

}

extension TabBarController: TabBarDelegate {

    func tabBar(_ tabBar: TabBar, didSelectItemAtIndex index: Int) {
        if !shouldScrollTabBar {
            containerScrollView.setContentOffset(CGPoint(x: view.bounds.width * CGFloat(index), y: 0), animated: true)
        }
        guard let viewControllers = viewControllers else { return }
        delegate?.tabBarController(self, didSelect: viewControllers[index])
    }

}


extension TabBarController: UIScrollViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        shouldScrollTabBar = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldScrollTabBar, let viewControllers = viewControllers else { return }
        tabBar.continuousIndex = min(max(0, scrollView.contentOffset.x / view.bounds.width), CGFloat(viewControllers.count - 1))
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        shouldScrollTabBar = false
    }

}
