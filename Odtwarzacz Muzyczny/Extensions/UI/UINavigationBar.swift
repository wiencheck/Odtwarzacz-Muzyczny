//
//  UIswift
//  Musico
//
//  Created by adam.wienconek on 10.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    static var height: CGFloat {
        return 44
    }
    
    var isBorderVisible: Bool {
        get {
            return shadowImage == nil
        } set {
            shadowImage = newValue ? nil : UIImage()
        }
    }
    
    var isBackgroundVisible: Bool {
        get {
            return backgroundImage(for: .default) == nil
        } set {
            let background: UIImage? = newValue ? nil : UIImage()
            setBackgroundImage(background, for: .default)
        }
    }
    
    var titleColor: UIColor? {
        get {
            return titleTextAttributes?[.foregroundColor] as? UIColor
        } set {
            if newValue == .clear {
                titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0)]
            } else {
                titleTextAttributes = [NSAttributedString.Key.foregroundColor: newValue ?? UIColor.white]
            }
        }
    }
    
    func setBorderColor(_ color: UIColor) {
        shadowImage = color.as1ptImage()
    }
    
}

extension UIColor {
    func as1ptImage() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
