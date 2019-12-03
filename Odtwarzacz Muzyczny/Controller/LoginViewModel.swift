//
//  LoginViewModel.swift
//  Odtwarzacz Muzyczny
//
//  Created by Adam Wienconek on 02/12/2019.
//  Copyright © 2019 Adam Wienconek. All rights reserved.
//

import Foundation

protocol LoginViewModelDelegate: class, Loadable {
    func loggedStatusDidChange(for source: AWMediaSource, success: Bool)
}

final class LoginViewModel {
    
    weak var delegate: LoginViewModelDelegate?
    
    private var desiredSources: [AWMediaSource] = [.iTunes, .spotify]
    
    private var finishedSources = Set<AWMediaSource>() {
        didSet {
            guard finishedSources.count == desiredSources.count else { return }
            delegate?.loadingDidEnd()
        }
    }
    
    func logIn(source: AWMediaSource) {
        var manager: SourceManager
        switch source {
        case .iTunes:
            manager = iTunesManager.shared
        case .spotify:
            manager = SpotifyManager.shared
        }
        manager.onLoggedInStatusChange = { [weak self] success in
            AppContext.shared.newRepo.f(from: [source], localCompletion: { localError in
                if let error = localError as? AWError {
                    if error.code == .notFound { return }
                    
                }
                if self?.finishedSources.contains(source) == true { return }
                self?.finishedSources.insert(source)
            }) { remoteError in
                if self?.finishedSources.contains(source) == true { return }
                self?.finishedSources.insert(source)
            }
            self?.delegate?.loggedStatusDidChange(for: source, success: success)
        }
        manager.logIn()
    }
    
}
