//
//  TabBarItemView.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 8/15/21.
//

import UIKit

internal final class TabBarItemView: UIView {

    internal var isSelected: Bool = false {
        didSet {
            updateColors()
        }
    }

    private let item: UITabBarItem

    private var rgbaDifference: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let selectedColorRGBA = tintColor.rgba
        let unselectedColorRGBA = UIColor.secondaryLabel.rgba
        return (selectedColorRGBA.red - unselectedColorRGBA.red,
                selectedColorRGBA.green - unselectedColorRGBA.green,
                selectedColorRGBA.blue - unselectedColorRGBA.blue,
                selectedColorRGBA.alpha - unselectedColorRGBA.alpha)
    }

    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .callout).withTraits(traits: .traitBold)
        label.textAlignment = .center
        return label
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        return tapGesture
    }()

    internal init(item: UITabBarItem) {
        self.item = item
        super.init(frame: .zero)

        addGestureRecognizer(tapGesture)
        translatesAutoresizingMaskIntoConstraints = false
        itemImageView.image = item.image
        titleLabel.text = item.title

        addSubview(itemImageView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),
            itemImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            itemImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            itemImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: layoutMargins.left),
            itemImageView.widthAnchor.constraint(equalTo: itemImageView.heightAnchor),
            itemImageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -(layoutMargins.left/2)),
            itemImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -(layoutMargins.right)),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal var didTapTabBarItem: (UITabBarItem) -> () = { _ in }

    internal func transitColor(withRatio ratio: CGFloat) {
        let transitionColor = UIColor(red: tintColor.rgba.red - rgbaDifference.red * ratio,
                                      green: tintColor.rgba.green - rgbaDifference.green * ratio,
                                      blue: tintColor.rgba.blue - rgbaDifference.blue * ratio,
                                      alpha: tintColor.rgba.alpha - rgbaDifference.alpha * ratio)
        titleLabel.textColor = transitionColor
        itemImageView.tintColor = transitionColor
    }

    @objc private func didTap() {
        didTapTabBarItem(item)
    }

    private func updateColors() {
        titleLabel.textColor = isSelected ? tintColor : .secondaryLabel
        itemImageView.tintColor = isSelected ? tintColor : .secondaryLabel
    }

}
