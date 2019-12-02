//
//  AWMessage.swift
//  Plum
//
//  Created by adam.wienconek on 11.12.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Spartan

struct AWMessage {
    let title: String
    let message: String?
    
    init(title: String, message: String? = nil) {
        self.title = title
        self.message = message
    }
    
    init(with error: Error, title: String = "Error") {
        self.title = title
        self.message = error.localizedDescription
    }
}

extension UIViewController {
    func displayAlert(with model: AlertViewModel) {
        DispatchQueue.main.async {
            self.present(AWAlertController.configure(with: model), animated: true, completion: nil)
        }
    }
    
    func displayMessage(_ message: AWMessage) {
        DispatchQueue.main.async {
            self.present({
                let alert = UIAlertController(title: message.title, message: message.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                return alert
            }(), animated: true, completion: nil)
        }
    }
}

extension AlertViewModel {
    init(message: AWMessage) {
        self.title = message.title
        self.message = message.message
        self.style = .alert
        self.actions = [
            UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        ]
    }
}
