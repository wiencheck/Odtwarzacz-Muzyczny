//
//  UIView.swift
//  Musico
//
//  Created by adam.wienconek on 27.08.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

extension UIView {
    func hideIfNil(_ v: Any?) {
        isHidden = v == nil
    }
    
    func pinTo(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    func pinToSuperviewEdges(_ edges: [NSLayoutConstraint.Attribute] = []) {
        guard let sup = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        if edges.contains(.top) {
            pinToTopEdge()
        } else if edges.contains(.leading) {
            pinToLeftEdge()
        } else if edges.contains(.bottom) {
            pinToBottomEdge()
        } else if edges.contains(.trailing) {
            pinToRightEdge()
        } else {
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: sup.leadingAnchor),
                trailingAnchor.constraint(equalTo: sup.trailingAnchor),
                topAnchor.constraint(equalTo: sup.topAnchor),
                bottomAnchor.constraint(equalTo: sup.bottomAnchor)
                ])
        }
    }
    
    func pinToTopEdge() {
        guard let sup = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: sup.topAnchor).isActive = true
    }
    
    func pinToBottomEdge() {
        guard let sup = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: sup.bottomAnchor).isActive = true
    }
    
    func pinToLeftEdge() {
        guard let sup = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: sup.leadingAnchor).isActive = true
    }
    
    func pinToRightEdge() {
        guard let sup = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        trailingAnchor.constraint(equalTo: sup.trailingAnchor).isActive = true
    }
}

extension UIView {
    @objc func dropShadow(color: UIColor = .black, opacity: Float = 0.5, offSet: CGSize = CGSize(width: 0, height: 1), radius: CGFloat = 2, scale: Bool = true) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = offSet  //Here you control x and y
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0 //Here your control your blur
        layer.masksToBounds =  false
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UIView {
    
    enum UIViewFadeStyle {
        case bottom
        case top
        case left
        case right
        
        case vertical
        case horizontal
    }
    
    func fadeView(style: UIViewFadeStyle = .bottom, percentage: Double = 0.07) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        
        let startLocation = percentage
        let endLocation = 1 - percentage
        
        switch style {
        case .bottom:
            gradient.startPoint = CGPoint(x: 0.5, y: endLocation)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .top:
            gradient.startPoint = CGPoint(x: 0.5, y: startLocation)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        case .vertical:
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0, startLocation, endLocation, 1.0] as [NSNumber]
            
        case .left:
            gradient.startPoint = CGPoint(x: startLocation, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.5)
        case .right:
            gradient.startPoint = CGPoint(x: endLocation, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        case .horizontal:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0, startLocation, endLocation, 1.0] as [NSNumber]
        }
        
        layer.mask = gradient
    }

}
