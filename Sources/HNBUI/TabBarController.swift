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

    private var shouldScrollTabBar = true

    public var selectedViewController: UIViewController? {
        get {
            guard let selectedIndex = selectedIndex else {
                return nil
            }
            return viewControllers[selectedIndex]
        }
        set {
            guard let newValue = newValue, let index = viewControllers.firstIndex(of: newValue) else {
                fatalError("Only a view controller in the tab bar controller's list of view controllers can be selected.")
            }
            selectedIndex = index
        }
    }

    public var selectedIndex: Int? {
        didSet(oldValue) {
            guard let selectedIndex = selectedIndex,
                  selectedIndex < viewControllers.count,
                  selectedIndex >= 0,
                  selectedIndex != oldValue,
                  let selectedItem = tabBar.selectedItem
            else {
                return
            }
            shouldScrollTabBar = selectedIndex == tabBar.items.firstIndex(of: selectedItem) ? false : true
            containerScrollView.isScrollEnabled = shouldScrollTabBar
            containerScrollView.setContentOffset(CGPoint(x: view.bounds.width * CGFloat(selectedIndex), y: 0), animated: true)
        }
    }

    public var viewControllers: [UIViewController] = [] {
        didSet(oldValue) {
            oldValue.forEach { viewController in
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
            tabBar.items = viewControllers.map { viewController in
                viewController.tabBarItem
            }
            containerScrollView.isScrollEnabled = true
            if viewControllers.count > 0 {
                containerScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(viewControllers.count), height: containerScrollView.bounds.height)
                addSelectedViewController()
            } else {
                containerScrollView.contentSize = CGSize(width: 0, height: 0)
                selectedIndex = nil
            }
        }
    }

    public let tabBar: TabBar = {
        let tabBar = TabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.backgroundColor = .clear
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

        view.addSubview(containerScrollView)
        view.addSubview(tabBar)

        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            containerScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
        containerScrollView.delegate = self
    }

    private func addSelectedViewController() {
        guard let selectedViewController = selectedViewController,
              let selectedIndex = selectedIndex,
              !children.contains(selectedViewController)
        else {
            return
        }
        selectedViewController.additionalSafeAreaInsets.top = tabBar.bounds.height
        addChild(selectedViewController)
        containerScrollView.addSubview(selectedViewController.view)
        selectedViewController.view.frame.origin.x = view.bounds.width * CGFloat(selectedIndex)
        selectedViewController.view.frame.size = containerScrollView.frame.size
        selectedViewController.didMove(toParent: self)
    }

}

extension TabBarController: TabBarDelegate {

    public func tabBar(_ tabBar: TabBar, didSelectItem item: UITabBarItem, atIndex index: Int) {
        selectedIndex = index
        delegate?.tabBarController(self, didSelect: viewControllers[index])
    }

}


extension TabBarController: UIScrollViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        shouldScrollTabBar = true
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        shouldScrollTabBar = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if shouldScrollTabBar {
            tabBar.setContinuousIndex(scrollView.contentOffset.x / view.bounds.width)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        addSelectedViewController()
        containerScrollView.isScrollEnabled = true
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        addSelectedViewController()
        containerScrollView.isScrollEnabled = true
    }

}
