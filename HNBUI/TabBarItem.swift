//
//  TabBarItem.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 4/10/21.
//

import UIKit

final class TabBarItem: UIView {

    private let item: UITabBarItem

    var isSelected: Bool = false {
        didSet {
            titleLabel.textColor = isSelected ? .systemOrange : .secondaryLabel
            itemImageView.tintColor = isSelected ? .systemOrange : .secondaryLabel
        }
    }

    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTabBarItem))
        return tapGesture
    }()

    init(item: UITabBarItem, didTapTabBarItemCallback callback: @escaping (UITabBarItem) -> ()) {
        self.item = item
        super.init(frame: .zero)

        addGestureRecognizer(tapGesture)
        translatesAutoresizingMaskIntoConstraints = false
        itemImageView.image = item.image
        titleLabel.text = item.title
        didTapTabBarItemCallback = callback

        addSubview(itemImageView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            itemImageView.heightAnchor.constraint(equalToConstant: 20),
            itemImageView.widthAnchor.constraint(equalToConstant: 20),
            itemImageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            itemImageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            itemImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 5),
            itemImageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -5)
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var didTapTabBarItemCallback: (UITabBarItem) -> () = { _ in }

    @objc private func didTapTabBarItem() {
        didTapTabBarItemCallback(item)
    }

}
