//
//  LoginViewController.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 02/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func LoginViewController(didFinishLoggingIn controller: LoginViewController)
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewControllerDelegate?
    
    @IBOutlet private weak var iTunesIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var iTunesButton: UIButton!
    @IBOutlet private weak var spotifyIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var spotifyButton: UIButton!
    
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        viewModel = LoginViewModel()
        viewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //delegate?.LoginViewController(didFinishLoggingIn: self)
    }
    
    @IBAction private func iTunesPressed() {
        iTunesIndicator.startAnimating()
        viewModel.logIn(source: .iTunes)
    }
    
    @IBAction private func spotifyPressed() {
        spotifyIndicator.startAnimating()
        viewModel.logIn(source: .spotify)
    }
    
}

extension LoginViewController: LoginViewModelDelegate {
    func loggedStatusDidChange(for source: AWMediaSource, success: Bool) {
        DispatchQueue.main.async {
            switch source {
            case .iTunes:
                self.iTunesIndicator.stopAnimating()
                self.iTunesButton.setTitle(success ? "iTunes zalogowany" : "Wystąpił błąd", for: .normal)
            case .spotify:
                self.spotifyIndicator.stopAnimating()
                self.spotifyButton.setTitle(success ? "Spotify zalogowany" : "Wystąpił błąd", for: .normal)
            }
        }
    }
    
    func loadingDidEnd() {
        DispatchQueue.main.async {
            self.delegate?.LoginViewController(didFinishLoggingIn: self)
        }
    }
}
