//
//  TabBar.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit

internal protocol TabBarDelegate: AnyObject {

    func tabBar(_ tabBar: TabBar, didSelectItemAtIndex index: Int)

}

public final class TabBar: UIView {

    internal weak var delegate: TabBarDelegate?

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

    public var selectedItemIndex: Int {
        get {
            Int(_continuousIndex.rounded(.toNearestOrAwayFromZero))
        }
        set {
            _continuousIndex = CGFloat(newValue)
            adjustTabBarItemPosition(to: _continuousIndex, animated: true)
        }
//        didSet {
//            highlightItemAtIndex()
//        }
    }

    internal var continuousIndex: CGFloat {
        get {
            return _continuousIndex
        }
        set {
//            selectedItemIndex = Int(continuousIndex.rounded(.toNearestOrAwayFromZero))
            _continuousIndex = newValue
            adjustTabBarItemPosition(to: _continuousIndex, animated: false)
        }
    }

    private var _continuousIndex: CGFloat = 0 {
        didSet(oldValue) {
            let oldSelectedItemIndex = Int(oldValue.rounded(.toNearestOrAwayFromZero))
            if (oldSelectedItemIndex != selectedItemIndex) {
                guard let tabBarItems = hStack.arrangedSubviews as? [TabBarItemView] else { return }
                tabBarItems.forEach { tabBarItem in
                    tabBarItem.isSelected = false
                }
                tabBarItems[selectedItemIndex].isSelected = true
                delegate?.tabBar(self, didSelectItemAtIndex: selectedItemIndex)
            }
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
//        strongSelf.delegate?.tabBar(strongSelf, didSelectItemAtIndex: index, didSelectSameItem: strongSelf.selectedItemIndex == index)
//        strongSelf.adjustTabBarItemPosition(to: CGFloat(index), animated: true)
        strongSelf.selectedItemIndex = index
    }

    private func highlightItemAtIndex() {
//        guard let tabBarItems = hStack.arrangedSubviews as? [TabBarItemView] else { return }
//        tabBarItems.forEach { tabBarItem in
//            tabBarItem.isSelected = false
//        }
//        tabBarItems[selectedItemIndex].isSelected = true
    }

    private func configure() {
        hStack.subviews.forEach { view in
            view.removeFromSuperview()
        }
        items.forEach { item in
            let tabBarItem = TabBarItemView(item: item, didTapTabBarItemCallback: didTapTabBarItemCallback)
            hStack.addArrangedSubview(tabBarItem)
        }
        if items.count > 0 {
            selectedItemIndex = 0
        }
    }

    private func adjustTabBarItemPosition(to index: CGFloat, animated: Bool) {
        let distanceBetweenItems = (contentOffsetXToCenterTabBarItem(at: Int(index) + 1) - contentOffsetXToCenterTabBarItem(at: Int(index))) * continuousIndex.truncatingRemainder(dividingBy: 1)
        let contentOffsetX = contentOffsetXToCenterTabBarItem(at: Int(index)) + distanceBetweenItems
        scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: animated)
    }

    private func contentOffsetXToCenterTabBarItem(at index: Int) -> CGFloat {
        guard index >= 0, index < items.count else {
            return 0
        }
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

    fileprivate init(item: UITabBarItem, didTapTabBarItemCallback callback: @escaping (UITabBarItem) -> ()) {
        self.item = item
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
        titleLabel.textColor = isSelected ? tintColor : .secondaryLabel
        itemImageView.tintColor = isSelected ? tintColor : .secondaryLabel
    }

}
