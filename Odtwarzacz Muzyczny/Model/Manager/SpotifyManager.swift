//
//  SpotifyManagerC.swift
//  Plum
//
//  Created by Adam Wienconek on 30/09/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Spartan

class SpotifyManager: SourceManager {
    
    static let shared = SpotifyManager()
        
    private let auth: SPTAuth
            
            private(set) var isLoggedIn = false {
                didSet {
                    let session = isLoggedIn ? auth.session : nil
                    onLoggedInStatusChange?(isLoggedIn)
                    NotificationCenter.default.post(name: SpotifyConstants.Notifications.sessionUpdated, object: session)
                }
            }
            
            class var user: String? {
                get {
                    return UserDefaults.standard.string(forKey: SpotifyConstants.usernameDefaultsKey)
                } set {
                    UserDefaults.standard.set(newValue, forKey: SpotifyConstants.usernameDefaultsKey)
                }
            }
            
            private var sessionObserver: Any?
            private var connectionObserver: Any?
            
            var onLoggedInStatusChange: ((Bool) -> Void)?
    
    private var sessionTimer: Timer!
        
        private init() {
            auth = SPTAuth.defaultInstance()
            /* Set up necessary SPTAuth properties */
            auth.clientID = SpotifyConstants.clientID
            
            let scopes = [
                SPTAuthStreamingScope,
                SPTAuthUserReadTopScope,
                SPTAuthUserFollowReadScope,
                SPTAuthUserLibraryReadScope,
                SPTAuthUserReadPrivateScope,
                SPTAuthUserFollowModifyScope,
                SPTAuthUserLibraryModifyScope,
                SPTAuthPlaylistReadPrivateScope,
                SPTAuthPlaylistModifyPublicScope,
                SPTAuthPlaylistModifyPrivateScope,
                SPTAuthPlaylistReadCollaborativeScope
            ]
            
            auth.requestedScopes = scopes
            auth.redirectURL = SpotifyConstants.redirectURL
//            auth.tokenSwapURL = SpotifyConstants.tokenSwapURL
//            auth.tokenRefreshURL = SpotifyConstants.tokenRefreshURL
        }
    
    deinit {
        sessionTimer?.invalidate()
    }
    
    private func checkSessionIsValid() {
        guard let session = auth.session else {
            
            return
        }
        guard session.isValid() else {
            renewSession(session)
            return
        }
        let expirationDate = session.expirationDate
        let secondsBetween = Date.secondsBetween(start: Date(), end: expirationDate)
        if secondsBetween > 300 {
            return
        }
        renewSession(session)
    }
    
    func logIn() {
        /* Add observer for whenever the session is updated */
            
            if sessionObserver == nil {
                sessionObserver = NotificationCenter.default.addObserver(forName: SpotifyConstants.Notifications.sessionUrlReceived, object: nil, queue: nil) { notification in
                    
                    guard let url = notification.object as? URL else { return }
                    
                    self.auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { error, session in
                        if let error = error {
                            print("Błąd przy authCallback w AppDelegate: " + error.localizedDescription)
                        } else if let session = session {
                            self.configureNewSession(session)
                        }
                    })
                }
            }
            
            // Observe internet connection changes
            observeInternetConnectionChange()
            if NetworkMonitor.shared.interfaceType == .none {
                isLoggedIn = false
                return
            }
            
            if let savedSession = SpotifyManager.loadSession() {
                auth.session = savedSession
            }
            
            /*
             Check if session currently exists
             Otherwise show up login screen
             */
            guard let session = auth.session else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.authorize()
                    //SpotifyManager.loginController().show()
                }
                return
            }
            
            /*
             Check if current session is valid
             Otherwise renew
             */
            guard session.isValid() else {
                SpotifyManager.authorize()
                //renewSession(session)
                return
            }
            
            /*
             Configure app with valid session
             */
            configureNewSession(session)
        }
    
            
            func logOut() {
                isLoggedIn = false
                removeSession()
            }
            
            private func renewSession(_ session: SPTSession) {
                auth.renewSession(session) { error, nSession in
                    if let error = error as NSError? {
                        print(error.localizedDescription)
                        if error.code == AWError.Code.connectionOffline.rawValue {
                            self.observeInternetConnectionChange()
                        }
                    } else if let nSession = nSession {
                        self.configureNewSession(nSession)
                    }
                }
            }
            
            private func observeInternetConnectionChange() {
                guard connectionObserver == nil else { return }
                
                connectionObserver = NotificationCenter.default.addObserver(forName: NetworkMonitor.connectionChangedNotification, object: nil, queue: nil) { notification in
                    guard let interface = notification.object as? NetworkMonitor.InterfaceType else {
                            return
                    }
                    
                    if interface == .none {
                        self.isLoggedIn = false
                    } else {
                        if let session = self.auth.session {
                            self.renewSession(session)
                        } else {
                            self.logIn()
                        }
                    }
                }
            }
            
            private func configureNewSession(_ session: SPTSession) {
                guard session.isValid() else {
                    Spartan.authorizationToken = nil
                    print("*** Session is not valid ***")
                    return
                }
                print("*** Configuring new session. ***")
                auth.session = session
                Spartan.authorizationToken = session.accessToken
                SpotifyManager.user = session.canonicalUsername
                
                isLoggedIn = true
                observeInternetConnectionChange()
                
                SpotifyManager.saveSession(session)
                
                guard sessionTimer == nil else { return }
                sessionTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true, block: { _ in
                    self.checkSessionIsValid()
                })
            }
            
            func authorize() {
                if let session = auth.session {
                    renewSession(session)
                } else {
                    let url = auth.spotifyWebAuthenticationURL()
                    UIApplication.openURL(url)
                    return
                    // TODO
                    if SPTAuth.supportsApplicationAuthentication() {
                        UIApplication.shared.open(SPTAuth.defaultInstance().spotifyAppAuthenticationURL(), options: [:], completionHandler: nil)
                    } else {
                        let url = auth.spotifyWebAuthenticationURL()
                        UIApplication.openURL(url)
                    }
                }
            }
    
    class func authorize() {
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open(SPTAuth.defaultInstance().spotifyAppAuthenticationURL(), options: [:], completionHandler: nil)
        } else {
            let url = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
            UIApplication.openURL(url)
        }
    }
    
    public class func openSpotifyApplication(with url: URL) {
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
        
}

extension SpotifyManager {
        private class func saveSession(_ session: SPTSession) {
            do {
                let sessionData = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
                UserDefaults.standard.set(sessionData, forKey: SpotifyConstants.sessionUserDefaultsKey)
            } catch let error {
                print("*** Could not save SPTSession to UserDefaults with error: \(error) ***")
            }
        }
        
        private class func loadSession() -> SPTSession? {
            guard let savedSessionData = UserDefaults.standard.data(forKey: SpotifyConstants.sessionUserDefaultsKey),
                let savedSession = try? NSKeyedUnarchiver.unarchivedObject(ofClass: SPTSession.self, from: savedSessionData) else {
                return nil
            }
            return savedSession
        }
    
        /// Removes saved session object from UserDefaults
        private func removeSession() {
            UserDefaults.standard.removeObject(forKey: SpotifyConstants.sessionUserDefaultsKey)
        }
        
        class func loginController() -> AWAlertController {
            let actions: [UIAlertAction] = [
                UIAlertAction(title: LocalizedStringKey.cancel.localized, style: .cancel, handler: { _ in
                    SpotifyManager.shared.logOut()
                }),
                UIAlertAction(title: LocalizedStringKey.spotifyOpenApp.localized, style: .default, handler: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        SpotifyManager.shared.authorize()
                    })
                })
            ]
            
            let model = AlertViewModel(title: "Spotify", message: LocalizedStringKey.spotifyAllowInAppMessage.localized, actions: actions, style: .alert)
            let alert = AWAlertController.configure(with: model)
            return alert
        }
    
}
