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
            guard let viewControllers = viewControllers,
                  viewControllers.count > 0
            else {
                containerScrollView.contentSize = CGSize(width: 0, height: 0)
                children.forEach { childViewController in
                    childViewController.willMove(toParent: nil)
                    childViewController.view.removeFromSuperview()
                    childViewController.removeFromParent()
                }
                return
            }
            tabBar.items = viewControllers.map { viewController in
                viewController.tabBarItem
            }
            containerScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(viewControllers.count), height: containerScrollView.bounds.height)
            viewControllers[0].view.frame.size = containerScrollView.bounds.size
            addChild(viewControllers[0])
            containerScrollView.addSubview(viewControllers[0].view)
            viewControllers[0].didMove(toParent: self)
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
            containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
        containerScrollView.delegate = self
    }

    private func addViewController(atContinuousIndex continuousIndex: CGFloat) {
        guard let viewControllers = viewControllers else { return }
        let indices = [Int(ceil(continuousIndex)), Int(floor(continuousIndex))]
        indices.forEach { index in
            guard index < viewControllers.count, index >= 0 else { return }
            addChild(viewControllers[index])
            viewControllers[index].view.frame.origin.x = view.bounds.width * CGFloat(index)
            viewControllers[index].view.frame.size = containerScrollView.frame.size
            containerScrollView.addSubview(viewControllers[index].view)
            viewControllers[index].didMove(toParent: self)
        }
    }

    private func removeUnselectedViewControllers() {
        guard let selectedItem = tabBar.selectedItem else { return }
        children.forEach { viewController in
            guard viewController.tabBarItem != selectedItem else { return }
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }

}

extension TabBarController: TabBarDelegate {

    public func tabBar(_ tabBar: TabBar, didSelectItem item: UITabBarItem) {
        guard let viewControllers = viewControllers,
              let index = tabBar.items.firstIndex(of: item)
        else {
            return
        }
        addViewController(atContinuousIndex: CGFloat(index))
        if !shouldScrollTabBar {
            containerScrollView.setContentOffset(CGPoint(x: view.bounds.width * CGFloat(index), y: 0), animated: true)
        }
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
        guard shouldScrollTabBar,
              let viewControllers = viewControllers
        else { return }
        addViewController(atContinuousIndex: scrollView.contentOffset.x / view.bounds.width)
        tabBar.setContinuousIndex(min(max(0, scrollView.contentOffset.x / view.bounds.width), CGFloat(viewControllers.count - 1)), animated: false)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        shouldScrollTabBar = false
        removeUnselectedViewControllers()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        removeUnselectedViewControllers()
    }

}
