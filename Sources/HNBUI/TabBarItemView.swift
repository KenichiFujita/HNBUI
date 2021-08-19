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

    private let hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
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

        if item.image != nil {
            hStack.addArrangedSubview(itemImageView)
        }
        hStack.addArrangedSubview(titleLabel)
        addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: directionalLayoutMargins.leading * 2),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -directionalLayoutMargins.trailing * 2),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
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
