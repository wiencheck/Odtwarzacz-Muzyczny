//
//  MPVolumeView.swift
//  Plum 2
//
//  Created by Adam Wienconek on 14.06.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

extension MPVolumeView {
    var slider: UISlider? {
        return subviews.first(where: { $0 is UISlider }) as? UISlider
    }
    
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume;
        }
    }
    
    func setVolume(_ volume: Float) {
        let slider = subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume;
        }
    }
    
    @objc static func showRoutePicker() {
        let mpView = MPVolumeView()
        mpView.showsRouteButton = false
        for view in mpView.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
    }
    
    @objc func showRoutePicker() {
        for view in subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
    }
    
    @IBInspectable var showsAirplayButton: Bool {
        get {
            return showsRouteButton
        } set {
            showsRouteButton = newValue
        }
    }
}
