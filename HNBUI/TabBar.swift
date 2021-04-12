//
//  TabBar.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit

public protocol TabBarDelegate: AnyObject {

    func tabBar(_ tabBar: TabBar, didSelectItemAt index: Int)

}

public final class TabBar: UIView {

    public weak var delegate: TabBarDelegate?

    public var items: [UITabBarItem] = [] {
        didSet {
            configure()
        }
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let hStack: UIStackView = {
        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.alignment = .center
        return hStack
    }()

    public init() {
        super.init(frame: .zero)

        backgroundColor = .systemBackground

        addSubview(scrollView)
        scrollView.addSubview(hStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hStack.topAnchor.constraint(equalTo: self.topAnchor),
            hStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var didTapTabBarItemCallback: (UITabBarItem) -> () = { [weak self] tabBarItem in

        guard let strongSelf = self, let index = strongSelf.items.firstIndex(of: tabBarItem) else { return }
        strongSelf.selectItem(at: index)

    }

    private func selectItem(at index: Int) {

        delegate?.tabBar(self, didSelectItemAt: index)
        guard let tabBarItems = hStack.arrangedSubviews as? [TabBarItem] else { return }
        tabBarItems.forEach { tabBarItem in
            tabBarItem.isSelected = false
        }
        tabBarItems[index].isSelected = true
        let offset = hStack.arrangedSubviews[index].center.x + 10 - (bounds.width / 2)
        if offset < 0 {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if offset + bounds.width > hStack.bounds.width + 20 {
            scrollView.setContentOffset(CGPoint(x: hStack.bounds.width + 20 - bounds.width, y: 0), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }

    }

    private func configure() {

        hStack.subviews.forEach { view in
            view.removeFromSuperview()
        }
        items.forEach { item in
            let tabBarItem = TabBarItem(item: item, didTapTabBarItemCallback: didTapTabBarItemCallback)
            hStack.addArrangedSubview(tabBarItem)
        }
        if items.count > 0 {
            selectItem(at: 0)
        }

    }

}
