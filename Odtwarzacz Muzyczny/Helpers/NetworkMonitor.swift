//
//  NetworkMonitor.swift
//  Plum
//
//  Created by Adam Wienconek on 23.06.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Network

@available (iOS 12.0, *)
class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    static let connectionChangedNotification = Notification.Name("connectionChangedNotification")
    
    public var shouldLogToConsole = true
    
    /// Currently used network interface. Nil if no connection is available.
    private(set) var interfaceType: InterfaceType = .none {
        didSet {
            if shouldLogToConsole {
                switch interfaceType {
                case .wifi:
                    print("Device is connected to the wifi")
                case .cellular:
                    print("Device is connected to the cellular network")
                case .other:
                    print("Device is connected to the internet")
                case .none:
                    print("Device has no internet connection")
                }
            }
            
            // Don't post notification if interface did not change.
            guard interfaceType != oldValue else { return }
            NotificationCenter.default.post(name: NetworkMonitor.connectionChangedNotification, object: interfaceType)
        }
    }
    
    public var isReducingDataUsage: Bool {
        return false
    }
    
    private let monitor: NWPathMonitor
    
    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            guard path.status == .satisfied else {
                self.interfaceType = .none
                return
            }
            
            if path.usesInterfaceType(.wifi) {
                self.interfaceType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self.interfaceType = .cellular
            } else {
                self.interfaceType = .other
            }
        }
    }
    
    deinit {
        monitor.cancel()
    }
    
    func start() {
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }
    
    // TODO dodać .none
    enum InterfaceType: String {
        case wifi
        case cellular
        case other
        case none
    }
    
}
