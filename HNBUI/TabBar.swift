//
//  TabBar.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit

public protocol TabBarDelegate: AnyObject {

    func tabBar(_ tabBar: TabBar, didTapSelectedItemAtIndex index: Int)

}

internal protocol TabBarInternalDelegate: AnyObject {

    func tabBar(_ tabBar: TabBar, didSelectItemAtIndex index: Int)

}

public final class TabBar: UIView {

    internal weak var delegate: TabBarDelegate?

    internal weak var internalDelegate: TabBarInternalDelegate?

    public var unselectedItemTintColor: UIColor?

    public var barTintColor: UIColor? {
        didSet {
            self.backgroundColor = barTintColor
        }
    }

    public var items: [UITabBarItem] = [] {
        didSet {
            configure()
        }
    }

    public private(set) var selectedItemIndex = 0

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

    internal init() {
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
            hStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ])

    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var didTapTabBarItemCallback: (UITabBarItem) -> () = { [weak self] tabBarItem in
        guard let strongSelf = self, let index = strongSelf.items.firstIndex(of: tabBarItem) else { return }
        if strongSelf.selectedItemIndex == index {
            strongSelf.delegate?.tabBar(strongSelf, didTapSelectedItemAtIndex: index)
        } else {
            strongSelf.selectItemAtIndex(index)
            strongSelf.internalDelegate?.tabBar(strongSelf, didSelectItemAtIndex: index)
        }
    }

    internal func highlightItemAtIndex(_ index: Int) {
        guard let tabBarItems = hStack.arrangedSubviews as? [TabBarItemView] else { return }
        tabBarItems.forEach { tabBarItem in
            tabBarItem.isSelected = false
        }
        tabBarItems[index].isSelected = true
    }

    internal func selectItemAtIndex(_ index: Int) {
        highlightItemAtIndex(index)
        selectedItemIndex = index
        scrollView.setContentOffset(CGPoint(x: contentOffsetXToCenterTabBarItem(at: index), y: 0), animated: true)
    }

    private func configure() {
        hStack.subviews.forEach { view in
            view.removeFromSuperview()
        }
        items.forEach { item in
            let tabBarItem = TabBarItemView(item: item, unselectedItemTintColor: unselectedItemTintColor, didTapTabBarItemCallback: didTapTabBarItemCallback)
            hStack.addArrangedSubview(tabBarItem)
        }
        if items.count > 0 {
            selectItemAtIndex(0)
        }
    }

    internal func adjustTabBarItemPosition(byRate contentOffsetXMoveRate: CGFloat) {
        let nextIndex = contentOffsetXMoveRate > 0 ? selectedItemIndex + 1 : selectedItemIndex - 1
        guard nextIndex >= 0, nextIndex < items.count else { return }
        let currentSelectedItemContentOffset = contentOffsetXToCenterTabBarItem(at: selectedItemIndex)
        let distanceFromCurrentItemToNextItem = abs(contentOffsetXToCenterTabBarItem(at: selectedItemIndex) - contentOffsetXToCenterTabBarItem(at: nextIndex))
        highlightItemAtIndex(abs(contentOffsetXMoveRate) < 0.5 ? selectedItemIndex : nextIndex)
        scrollView.setContentOffset(CGPoint(x: currentSelectedItemContentOffset + (distanceFromCurrentItemToNextItem * contentOffsetXMoveRate), y: 0), animated: false)
    }

    private func contentOffsetXToCenterTabBarItem(at index: Int) -> CGFloat {
        let offset = hStack.arrangedSubviews[index].center.x + scrollView.layoutMargins.left - (bounds.width / 2)
        let minimumOffset: CGFloat = 0
        let maximumOffset = hStack.bounds.width - bounds.width
        return min(max(minimumOffset, offset), maximumOffset)
    }

}


final class TabBarItemView: UIView {

    private let item: UITabBarItem

    private var unselectedItemTintColor: UIColor?

    fileprivate var isSelected: Bool = false {
        didSet {
            updateColors()
        }
    }

    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        return tapGesture
    }()

    fileprivate init(item: UITabBarItem, unselectedItemTintColor: UIColor?, didTapTabBarItemCallback callback: @escaping (UITabBarItem) -> ()) {
        self.item = item
        self.unselectedItemTintColor = unselectedItemTintColor
        super.init(frame: .zero)

        addGestureRecognizer(tapGesture)
        translatesAutoresizingMaskIntoConstraints = false
        itemImageView.image = item.image
        titleLabel.text = item.title
        didTapTabBarItem = callback
        updateColors()

        addSubview(itemImageView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            itemImageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            itemImageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            itemImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: layoutMargins.left),
            itemImageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -(layoutMargins.left)),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -(layoutMargins.right))
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var didTapTabBarItem: (UITabBarItem) -> () = { _ in }

    @objc private func didTap() {
        didTapTabBarItem(item)
    }

    private func updateColors() {
        titleLabel.textColor = isSelected ? tintColor : unselectedItemTintColor ?? .secondaryLabel
        itemImageView.tintColor = isSelected ? tintColor : unselectedItemTintColor ?? .secondaryLabel
    }

}
