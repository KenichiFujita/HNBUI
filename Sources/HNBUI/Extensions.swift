//
//  Extensions.swift
//  HNBUI
//
//  Created by Kenichi Fujita on 8/15/21.
//

import UIKit

internal extension UIFont {

    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return UIFont()
        }
        return UIFont(descriptor: descriptor, size: 0)
    }

}

internal extension UIColor {

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }

}
