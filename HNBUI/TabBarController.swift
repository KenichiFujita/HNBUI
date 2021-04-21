//
//  TabBarController.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit

open class TabBarController: UIViewController, TabBarDelegate {

    private var shouldScrollTabBar = true

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
        tabBar.internalDelegate = self
        containerScrollView.delegate = self
    }

    open func tabBar(_ tabBar: TabBar, didTapSelectedItemAtIndex index: Int) { }

    open func tabBar(_ tabBar: TabBar, didTapItemAtIndex index: Int) { }

}

extension TabBarController: TabBarInternalDelegate {

    func tabBar(_ tabBar: TabBar, didSelectItemAtIndex index: Int) {
        shouldScrollTabBar = false
        containerScrollView.setContentOffset(CGPoint(x: view.bounds.width * CGFloat(index), y: 0), animated: true)
        self.tabBar(tabBar, didTapItemAtIndex: index)
    }

}


extension TabBarController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldScrollTabBar else { return }
        let scrollDistanceRate = (scrollView.contentOffset.x - (view.bounds.width * CGFloat(tabBar.selectedItemIndex))) / view.bounds.width
        if abs(scrollDistanceRate) > 1 {
            tabBar.selectItemAtIndex(min(viewControllers!.count - 1, max(0, tabBar.selectedItemIndex + Int(scrollDistanceRate))))
        } else {
            tabBar.adjustTabBarItemPosition(byRate: (scrollView.contentOffset.x - (view.bounds.width * CGFloat(tabBar.selectedItemIndex))) / view.bounds.width)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard shouldScrollTabBar else { return }
        tabBar.selectItemAtIndex(Int(scrollView.contentOffset.x / view.bounds.width))
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        shouldScrollTabBar = true
    }

}
