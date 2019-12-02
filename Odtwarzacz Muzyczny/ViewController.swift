//
//  ViewController.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 01/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let login = storyboard?.instantiateViewController(identifier: "login") as? LoginViewController else { return }
        login.delegate = self
        present(login, animated: true, completion: nil)
    }


}

extension InitialViewController: LoginViewControllerDelegate {
    func LoginViewController(didFinishLoggingIn controller: LoginViewController) {
        controller.dismiss(animated: true) {
            self.performSegue(withIdentifier: "success", sender: nil)
        }
    }
}

