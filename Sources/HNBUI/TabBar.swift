//
//  TabBar.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit

public protocol TabBarDelegate: AnyObject {

    func tabBar(_ tabBar: TabBar, didSelectItem item: UITabBarItem, atIndex index: Int)

}

public final class TabBar: UIView {

    public weak var delegate: TabBarDelegate?

    public override var tintColor: UIColor! {
        didSet {
            underBarView.backgroundColor = tintColor
        }
    }

    public var barTintColor: UIColor? {
        didSet {
            guard let barTintColor = barTintColor else { return }
            didChangeBarTintColor(barTintColor)
        }
    }

    public internal(set) var items: [UITabBarItem] = [] {
        didSet {
            configure()
        }
    }

    internal private(set) var selectedItem: UITabBarItem? {
        didSet {
            guard let selectedItem = selectedItem,
                  let index = items.firstIndex(of: selectedItem),
                  let tabBarItemViews = hStackView.arrangedSubviews as? [TabBarItemView]
             else {
                continuousIndex = nil
                return
            }
            tabBarItemViews.forEach { tabBarItemView in
                tabBarItemView.isSelected = false
            }
            tabBarItemViews[index].isSelected = true
            delegate?.tabBar(self, didSelectItem: selectedItem, atIndex: index)
        }
    }

    var didChangeBarTintColor: (UIColor) -> Void = { _ in }

    private var continuousIndex: CGFloat? {
        didSet {
            guard let continuousIndex = continuousIndex,
                  continuousIndex >= 0,
                  Int(continuousIndex) < hStackView.arrangedSubviews.count,
                  continuousIndex.truncatingRemainder(dividingBy: 1) == 0.0
            else {
                return
            }
            selectedItem = items[Int(continuousIndex)]
        }
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var underBarView: UIView = {
        let underBarView = UIView()
        underBarView.translatesAutoresizingMaskIntoConstraints = false
        underBarView.backgroundColor = tintColor
        return underBarView
    }()

    private let hStackView: UIStackView = {
        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.alignment = .center
        return hStack
    }()

    private lazy var underBarViewLeadingAnchorConstraint: NSLayoutConstraint? = {
        let underBarViewLeadingAnchorConstraint = underBarView.leadingAnchor.constraint(equalTo: hStackView.leadingAnchor)
        underBarViewLeadingAnchorConstraint.isActive = true
        return underBarViewLeadingAnchorConstraint
    }()

    private lazy var underBarViewWidthAnchorConstraint: NSLayoutConstraint? = {
        let underBarViewWidthAnchorConstraint = underBarView.widthAnchor.constraint(equalToConstant: 0)
        underBarViewWidthAnchorConstraint.isActive = true
        return underBarViewWidthAnchorConstraint
    }()

    private var leftTabBarItemView: TabBarItemView? {
        guard let continuousIndex = continuousIndex else { return nil }
        return hStackView.arrangedSubviews[Int(continuousIndex)] as? TabBarItemView
    }

    private var rightTabBarItemView: TabBarItemView? {
        guard let continuousIndex = continuousIndex else { return nil }
        return hStackView.arrangedSubviews[min(Int(continuousIndex) + 1, items.count - 1)] as? TabBarItemView
    }

    internal init() {
        super.init(frame: .zero)

        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.addSubview(hStackView)
        scrollView.addSubview(underBarView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hStackView.topAnchor.constraint(equalTo: topAnchor),
            hStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            underBarView.topAnchor.constraint(equalTo: hStackView.bottomAnchor, constant: -3),
            underBarView.bottomAnchor.constraint(equalTo: hStackView.bottomAnchor)
        ])
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setContinuousIndex(_ continuousIndex: CGFloat) {
        setContinuousIndex(continuousIndex, animated: false)
    }

    private func configure() {
        hStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        items.forEach { item in
            let tabBarItem = TabBarItemView(item: item)
            tabBarItem.didTapTabBarItem = didTapTabBarItemCallback
            hStackView.addArrangedSubview(tabBarItem)
        }
        if items.count > 0 {
            layoutIfNeeded()
            setContinuousIndex(0, animated: false)
        }
    }

    private lazy var didTapTabBarItemCallback: (UITabBarItem) -> () = { [weak self] tabBarItem in
        guard let strongSelf = self, let index = strongSelf.items.firstIndex(of: tabBarItem) else { return }
        strongSelf.setContinuousIndex(CGFloat(index), animated: true)
    }

     private func setContinuousIndex(_ continuousIndex: CGFloat, animated: Bool) {
        guard continuousIndex >= 0, Int(continuousIndex) < hStackView.arrangedSubviews.count else { return }
        self.continuousIndex = continuousIndex
        scrollView.setContentOffset(contentOffsetForContinuousIndex(continuousIndex), animated: animated)
        moveUnderBarView(toContinuousIndex: continuousIndex, animated: animated)
        transitTabBarItemTintColor(byContinuousIndex: continuousIndex)
    }

    private func contentOffsetForContinuousIndex(_ continuousIndex: CGFloat) -> CGPoint {
        let distanceBetweenItems = (contentOffsetXToCenterTabBarItem(at: Int(continuousIndex) + 1) - contentOffsetXToCenterTabBarItem(at: Int(continuousIndex))) * continuousIndex.truncatingRemainder(dividingBy: 1)
        let contentOffsetX = contentOffsetXToCenterTabBarItem(at: Int(continuousIndex)) + distanceBetweenItems
        return CGPoint(x: contentOffsetX, y: 0)
    }

    private func contentOffsetXToCenterTabBarItem(at index: Int) -> CGFloat {
        guard index >= 0, index < items.count else {
            return 0
        }
        let offset = hStackView.arrangedSubviews[index].center.x - (bounds.width / 2)
        let minimumOffset: CGFloat = 0
        let maximumOffset = hStackView.bounds.width - bounds.width
        return min(max(minimumOffset, offset), maximumOffset)
    }

    private func moveUnderBarView(toContinuousIndex continuousIndex: CGFloat, animated: Bool) {
        guard let leftTabBarItemView = leftTabBarItemView, let rightTabBarItemView = rightTabBarItemView else { return }
        let distanceBetweenItems =  (rightTabBarItemView.frame.origin.x - leftTabBarItemView.frame.origin.x) * continuousIndex.truncatingRemainder(dividingBy: 1)
        let widthDifference = (rightTabBarItemView.bounds.width - leftTabBarItemView.bounds.width) * continuousIndex.truncatingRemainder(dividingBy: 1)
        underBarViewLeadingAnchorConstraint?.constant = leftTabBarItemView.frame.origin.x + distanceBetweenItems + directionalLayoutMargins.leading
        underBarViewWidthAnchorConstraint?.constant = leftTabBarItemView.bounds.width + widthDifference - directionalLayoutMargins.leading * 2
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.layoutIfNeeded()
            })
        }
    }

    private func transitTabBarItemTintColor(byContinuousIndex continuousIndex: CGFloat) {
        guard let leftTabBarItemView = leftTabBarItemView, let rightTabBarItemView = rightTabBarItemView else { return }
        rightTabBarItemView.transitColor(withRatio: 1 - continuousIndex.truncatingRemainder(dividingBy: 1))
        leftTabBarItemView.transitColor(withRatio: continuousIndex.truncatingRemainder(dividingBy: 1))
    }

}
