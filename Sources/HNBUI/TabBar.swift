//
//  TabBar.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit

public protocol TabBarDelegate: AnyObject {

    func tabBar(_ tabBar: TabBar, didSelectItem item: UITabBarItem)

}

public final class TabBar: UIView {

    public weak var delegate: TabBarDelegate?

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

    public var selectedItem: UITabBarItem? {
        get {
            guard let continuousIndex = continuousIndex else {
                return nil
            }
            return items.count > 0 ? items[continuousIndex.roundedInt()] : nil
        }
        set {
            guard let item = newValue, let index = items.firstIndex(of: item) else {
                continuousIndex = nil
                return
            }
            setContinuousIndex(CGFloat(index), animated: true)
        }
    }

    private var continuousIndex: CGFloat? {
        didSet(oldValue) {
            guard continuousIndex?.roundedInt() != oldValue?.roundedInt(),
                  let tabBarItems = hStack.arrangedSubviews as? [TabBarItemView],
                  let continuousIndex = continuousIndex,
                  continuousIndex >= 0,
                  Int(continuousIndex) < tabBarItems.count else {
                return
            }
            tabBarItems.forEach { tabBarItem in
                tabBarItem.isSelected = false
            }
            tabBarItems[continuousIndex.roundedInt()].isSelected = true
            delegate?.tabBar(self, didSelectItem: items[continuousIndex.roundedInt()])
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

    internal func setContinuousIndex(_ continuousIndex: CGFloat, animated: Bool) {
        self.continuousIndex = continuousIndex
        scrollView.setContentOffset(contentOffsetForContinuousIndex(continuousIndex), animated: animated)
    }

    private lazy var didTapTabBarItemCallback: (UITabBarItem) -> () = { [weak self] tabBarItem in
        guard let strongSelf = self, let index = strongSelf.items.firstIndex(of: tabBarItem) else { return }
        strongSelf.selectedItem = strongSelf.items[index]
    }

    private func configure() {
        hStack.subviews.forEach { view in
            view.removeFromSuperview()
        }
        items.forEach { item in
            let tabBarItem = TabBarItemView(item: item)
            tabBarItem.didTapTabBarItem = didTapTabBarItemCallback
            hStack.addArrangedSubview(tabBarItem)
        }
        if items.count > 0 {
            selectedItem = items[0]
        }
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
        let offset = hStack.arrangedSubviews[index].center.x + scrollView.layoutMargins.left - (bounds.width / 2)
        let minimumOffset: CGFloat = 0
        let maximumOffset = hStack.bounds.width - bounds.width
        return min(max(minimumOffset, offset), maximumOffset)
    }

}


fileprivate final class TabBarItemView: UIView {

    private let item: UITabBarItem

    fileprivate var isSelected: Bool = false {
        didSet {
            updateColors()
        }
    }

    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        return label
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        return tapGesture
    }()

    fileprivate init(item: UITabBarItem) {
        self.item = item
        super.init(frame: .zero)

        addGestureRecognizer(tapGesture)
        translatesAutoresizingMaskIntoConstraints = false
        itemImageView.image = item.image
        titleLabel.text = item.title
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

    fileprivate var didTapTabBarItem: (UITabBarItem) -> () = { _ in }

    @objc private func didTap() {
        didTapTabBarItem(item)
    }

    private func updateColors() {
        titleLabel.textColor = isSelected ? tintColor : .secondaryLabel
        itemImageView.tintColor = isSelected ? tintColor : .secondaryLabel
    }

}

fileprivate extension CGFloat {

    func roundedInt() -> Int {
        return Int(self.rounded(.toNearestOrAwayFromZero))
    }

}
