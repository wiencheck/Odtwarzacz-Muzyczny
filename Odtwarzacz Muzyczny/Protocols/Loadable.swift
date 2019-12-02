//
//  Loadable.swift
//  Plum
//
//  Created by Adam Wienconek on 11.07.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

protocol Loadable {
    func loadingDidBegin()
    func loadingDidBegin(message: String?)
    func loadingDidEnd()
    func loadingDidEnd(error: Error?)
}

extension Loadable where Self: UIViewController {
    func loadingDidBegin() {
        
    }
    
    func loadingDidBegin(message: String?) {
        
    }
    
    func loadingDidEnd() {
        
    }
    
    func loadingDidEnd(error: Error?) {
        
    }
}

protocol Alertable {
    func didReceiveAlert(model: AlertViewModel)
}

extension Alertable where Self: UIViewController {
    func didReceiveAlert(model: AlertViewModel) {
        DispatchQueue.main.async {
            AWAlertController.configure(with: model).show()
            //self.present(AWAlertController.configure(with: model), animated: true, completion: nil)
        }
    }
}

protocol Errorable {
    func didReceiveMessage(_ message: AWMessage)
    func didEncounterError(_ error: Error)
}

extension Errorable where Self: UIViewController {
    func didReceiveMessage(_ message: AWMessage) {
        let model = AlertViewModel(message: message)
        DispatchQueue.main.async {
            self.present(AWAlertController.configure(with: model), animated: true, completion: nil)
        }
    }
    
    func didEncounterError(_ error: Error) {
        let message = AWMessage(with: error)
        let model = AlertViewModel(message: message)
        DispatchQueue.main.async {
            self.present(AWAlertController.configure(with: model), animated: true, completion: nil)
        }
    }
}

fileprivate final class LoadingViewController: UIViewController {
    
    private var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = UIActivityIndicatorView()
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        indicator.startAnimating()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return UIApplication.shared.isStatusBarHidden
    }
}
