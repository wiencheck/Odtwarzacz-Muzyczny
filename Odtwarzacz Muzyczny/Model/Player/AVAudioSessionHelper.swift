//
//  AVAudioSessionHelper.swift
//  Plum
//
//  Created by Adam Wienconek on 30/08/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import AVFoundation

protocol AVAudioSessionHelperDelegate: class {
    func audioSession(routeChanged newRoute: AudioOutputRoute, available: Bool)
    func audioSessionWasInterrupted(reason: AudioInterruptionReason)
    func audioSessionFinishedInterruption(shouldResume: Bool?)
    func audioSessionShouldStayActive() -> Bool
}

class AVAudioSessionHelper {
    
    weak var delegate: AVAudioSessionHelperDelegate!
    private let session: AVAudioSession
    
    init(delegate: AVAudioSessionHelperDelegate) {
        self.delegate = delegate
        session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback)
        addObservers()
    }
    
    var audioRoute: AudioOutputRoute {
        guard let route = AudioOutputRoute(route: session.currentRoute) else {
            return .default
        }
        return route
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main, using: { notification in
            self.handleAudioSessionInterruption(notification)
        })
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main, using: { notification in
            self.handleAudioRouteChanged(notification)
        })
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { sender in
            if self.delegate.audioSessionShouldStayActive() {
                return
            }
            //self.setSession(active: false)
        }
    }
    
    private func handleAudioSessionInterruption(_ notification: Notification){
        print("Interruption received: \(notification.description)")
        guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt, let interruptionType = AVAudioSession.InterruptionType(rawValue: typeInt) else { return }
        switch interruptionType {
        case .began:
            // This interrpution keys means that interruption has ended
            if let wasSuspended = userInfo[AVAudioSessionInterruptionWasSuspendedKey] as? Bool {
                print("Resuming audio session from being suspended: ", wasSuspended)
                //delegate.audioSessionFinishedInterruption(shouldResume: true)
                return
            }
            delegate.audioSessionWasInterrupted(reason: .other)
            setSession(active: false)
        case .ended:
            guard let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let interruptionOptions = AVAudioSession.InterruptionOptions(rawValue: optionsInt)
            let shouldResume = interruptionOptions.contains(.shouldResume)
            if shouldResume {
                setSession(active: true)
            }
            delegate.audioSessionFinishedInterruption(shouldResume: shouldResume)
        default:
            print("*** Received unknown interruptionType case ***")
        }
    }
    
    private func handleAudioRouteChanged(_ notification: Notification) {
        guard let rawValue = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as? UInt, let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue) else { return }
        
        let available = reason != .oldDeviceUnavailable
        delegate.audioSession(routeChanged: audioRoute, available: available)
        if available == false {
            setSession(active: false)
        }
    }
    
    @discardableResult
    func setSession(active: Bool) -> Error? {
        do {
            try session.setActive(active)
            return nil
        } catch let error {
            print("*** Failed to activate audio session: \(error.localizedDescription)")
            return error
        }
    }
    
}
