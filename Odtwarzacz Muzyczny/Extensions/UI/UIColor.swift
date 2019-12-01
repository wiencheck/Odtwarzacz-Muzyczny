//
//  UIColor.swift
//  Musico
//
//  Created by adam.wienconek on 14.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIColor {
    /**
     Create a ligher color
     */
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    /**
     Create a darker color
     */
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: -abs(percentage))
    }
    
    /**
     Try to increase brightness or decrease saturation
     */
    func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if b < 1.0 {
                let newB: CGFloat = max(min(b + (percentage/100.0)*b, 1.0), 0.0)
                return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
            } else {
                let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
                return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
            }
        }
        return self
    }
    
    func isEqualToColor(color: UIColor, withTolerance tolerance: CGFloat = 0.0) -> Bool{
        
        var r1 : CGFloat = 0
        var g1 : CGFloat = 0
        var b1 : CGFloat = 0
        var a1 : CGFloat = 0
        var r2 : CGFloat = 0
        var g2 : CGFloat = 0
        var b2 : CGFloat = 0
        var a2 : CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return
            abs(r1 - r2) <= tolerance &&
                abs(g1 - g2) <= tolerance &&
                abs(b1 - b2) <= tolerance &&
                abs(a1 - a2) <= tolerance
    }

    
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 100), 0) / 100
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }
            
            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                           green: CGFloat(g1 + (g2 - g1) * percentage),
                           blue: CGFloat(b1 + (b2 - b1) * percentage),
                           alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
    
    static let darkBackgroundColor = UIColor(red: 0.06274509803921569, green: 0.0784313725490196, blue: 0.08235294117647059, alpha: 1.0)
    static let darkContentBackgroundColor = UIColor(red: 0.08980392156862745, green: 0.10549019607843137, blue: 0.11725490196078433, alpha: 1.0)
    static let lightBackgroundColor = UIColor(red: 0.9529411764705882, green: 0.9647058823529412, blue: 0.9882352941176471, alpha: 1.0)
    static let lightContentBackgroundColor = UIColor(red: 0.996078431372549, green: 1.0, blue: 1.0, alpha: 1.0)
    
    enum CustomColors {
        static var backgroundColor = UIColor(red:0.063, green:0.071, blue:0.102, alpha: 1.000)
        static var slightlyLighterBackgroundColor = UIColor(red: 0.09313725866377354, green: 0.10294117964804173, blue: 0.15196078456938267, alpha: 1.0)
        static var contentBackground = UIColor(red:0.145, green:0.165, blue:0.216, alpha: 0.000)
        static var mainLabelColor = UIColor(red:1.000, green:0.988, blue:0.918, alpha: 1.000)
        static var detailLabelColor = UIColor(red:1.000, green:0.988, blue:0.925, alpha: 1.000)

        static var accentOrange = UIColor(red:0.855, green:0.584, blue:0.263, alpha: 1.000)
        static var accentPinkRed = UIColor(red:0.761, green:0.298, blue:0.361, alpha: 1.000)
        static var accentPurple = UIColor(red:0.369, green:0.278, blue:0.584, alpha: 1.000)
        static var accentBlue = UIColor(red:0.247, green:0.416, blue:0.875, alpha: 1.000)
        static var accentBeige = UIColor(red:0.718, green:0.686, blue:0.631, alpha: 1.000)
        static var accentGreen = UIColor(red:0.25, green:0.66, blue:0.27, alpha:1.0)
        static var iconGreen = UIColor(red: 0.23137255012989044, green: 0.572549045085907, blue: 0.48235294222831726, alpha: 1.0)
        static let spotifyGreen = UIColor(red: 0.13333333333333333, green: 0.8392156862745098, blue: 0.36470588235294116, alpha: 1.0)
    }
    
    static let systemBlue = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
    
    static let appleMusicPink = UIColor(red: 0.8901960849761963, green: 0.35686275362968445, blue: 0.5058823823928833, alpha: 1.0)
    
    static let spotifyGreen = UIColor(red: 0.1411764770746231, green: 0.7843137383460999, blue: 0.47058823704719543, alpha: 1.0)
    
    static var transparentLight: UIColor {
        return UIColor(named: "Transparent Light")!
    }
    
    static var transparentDark: UIColor {
        return UIColor(named: "Transparent Dark")!
    }
    
    static var dangerRed: UIColor {
        return UIColor(named: "Danger Red")!
    }
    
}

extension CGColor{
    var components: [CGFloat]{
        get{
            var red = CGFloat()
            var green = CGFloat()
            var blue = CGFloat()
            var alpha = CGFloat()
            UIColor(cgColor: self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return [red, green, blue, alpha]
        }
    }
}

extension UIColor {
    var isDarkColor: Bool{
        let RGB = self.cgColor.components
        return (0.2126 * RGB[0] + 0.7152 * RGB[1] + 0.0722 * RGB[2]) < 0.5
    }
}
