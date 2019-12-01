//
//  SpotifyManager.swift
//  Plum
//
//  Created by Adam Wienconek on 09.05.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import Foundation
import Spartan

//class SpotifyManager {
//
//    private static let auth = SPTAuth.defaultInstance()
//
//    static private(set) var isLoggedIn = false {
//        didSet {
//            let session = isLoggedIn ? auth.session : nil
//            loggedInStatusChangeHandler?(isLoggedIn)
//            NotificationCenter.default.post(name: SpotifyConstants.Notifications.sessionUpdated, object: session)
//        }
//    }
//
//    static var user: String? {
//        get {
//            return UserDefaults.standard.string(forKey: SpotifyConstants.usernameDefaultsKey)
//        } set {
//            UserDefaults.standard.set(newValue, forKey: SpotifyConstants.usernameDefaultsKey)
//        }
//    }
//
//    private static var sessionObserver: Any?
//    private static var connectionObserver: Any?
//
//    static var loggedInStatusChangeHandler: ((Bool) -> Void)?
//
//    class func start() {
//        /* Set up necessary SPTAuth properties */
//        auth.clientID = SpotifyConstants.clientID
//        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserLibraryReadScope, SPTAuthUserLibraryModifyScope, SPTAuthPlaylistReadPrivateScope]
//        auth.redirectURL = SpotifyConstants.redirectURL
//        auth.tokenSwapURL = SpotifyConstants.tokenSwapURL
//        auth.tokenRefreshURL = SpotifyConstants.tokenRefreshURL
//        //auth.sessionUserDefaultsKey = SpotifyConstants.sessionUserDefaultsKey
//
//        /* Add observer for whenever the session is updated */
//
//        if sessionObserver == nil {
//            sessionObserver = NotificationCenter.default.addObserver(forName: SpotifyConstants.Notifications.sessionUrlReceived, object: nil, queue: nil) { notification in
//
//                guard let url = notification.object as? URL else { return }
//
//                self.auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { error, session in
//                    if let error = error {
//                        print("Błąd przy authCallback w AppDelegate: " + error.localizedDescription)
//                    } else if let session = session {
//                        self.configureNewSession(session)
//                    }
//                })
//            }
//        }
//
//        // Observe internet connection changes
//        observeInternetConnectionChange()
//        if NetworkMonitor.shared.interfaceType == .none {
//            isLoggedIn = false
//            return
//        }
//
//        if let savedSession = loadSession() {
//            auth.session = savedSession
//        }
//
//        /*
//         Check if session currently exists
//         Otherwise show up login screen
//         */
//        guard let session = auth.session else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                UIApplication.shared.keyWindow?.rootViewController?.present(loginController(), animated: true, completion: nil)
//            }
//            return
//        }
//
//        /*
//         Check if current session is valid
//         Otherwise renew
//         */
//        guard session.isValid() else {
//            renewSession(session)
//            return
//        }
//
//        /*
//         Configure app with valid session
//         */
//        configureNewSession(session)
//    }
//
//    class func performWhenValid(completion: @escaping (Error?) -> Void) {
//        guard let session = auth.session else { return }
//        if session.isValid() {
//            completion(nil)
//            return
//        }
//        auth.renewSession(session) { error, newSession in
//            if let error = error {
//                completion(error)
//            } else if let newSession = newSession {
//                self.configureNewSession(newSession)
//                completion(nil)
//            }
//        }
//    }
//
////    public class func refresh() {
////        guard let session = auth.session else {
////            return
////        }
////        renewSession(session)
////    }
//
//    class func logOut() {
//        //auth.session = nil
//        isLoggedIn = false
//    }
//
//    private class func renewSession(_ session: SPTSession) {
//        auth.renewSession(session) { error, nSession in
//            if let error = error as NSError? {
//                print(error.localizedDescription)
//                if error.code == AWError.Code.connectionOffline.rawValue {
//                    observeInternetConnectionChange()
//                }
//            } else if let nSession = nSession {
//                self.configureNewSession(nSession)
//            }
//        }
//    }
//
//    private class func observeInternetConnectionChange() {
//        guard connectionObserver == nil else { return }
//
//        connectionObserver = NotificationCenter.default.addObserver(forName: NetworkMonitor.connectionChangedNotification, object: nil, queue: .main) { notification in
//            guard let interface = notification.object as? NetworkMonitor.InterfaceType else {
//                    return
//            }
//
//            if interface == .none {
//                isLoggedIn = false
//            } else {
//                if let session = auth.session {
//                    renewSession(session)
//                } else {
//                    start()
//                }
//            }
//        }
//    }
//
//    private class func configureNewSession(_ session: SPTSession) {
//        guard session.isValid() else {
//            Spartan.authorizationToken = nil
//            print("*** Session is not valid ***")
//            return
//        }
//        print("*** Configuring new session. ***")
//        auth.session = session
//        Spartan.authorizationToken = session.accessToken
//        user = session.canonicalUsername
//
//        isLoggedIn = true
//        observeInternetConnectionChange()
//
//        saveSession(session)
//    }
//
//    class func authorize() {
//        if let session = auth.session {
//            renewSession(session)
//        } else {
//            if SPTAuth.supportsApplicationAuthentication() {
//                UIApplication.shared.open(SPTAuth.defaultInstance().spotifyAppAuthenticationURL(), options: [:], completionHandler: nil)
//            } else {
//                let url = auth.spotifyWebAuthenticationURL()
//                UIApplication.openURL(url)
//            }
//        }
//    }
//
//}

//extension SpotifyManager {
//    private class func saveSession(_ session: SPTSession) {
//        do {
//            let sessionData = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
//            UserDefaults.standard.set(sessionData, forKey: SpotifyConstants.sessionUserDefaultsKey)
//        } catch let error {
//            print("*** Could not save SPTSession to UserDefaults with error: \(error) ***")
//        }
//    }
//    
//    private class func loadSession() -> SPTSession? {
//        guard let savedSessionData = UserDefaults.standard.data(forKey: SpotifyConstants.sessionUserDefaultsKey),
//            let savedSession = try? NSKeyedUnarchiver.unarchivedObject(ofClass: SPTSession.self, from: savedSessionData) else {
//            return nil
//        }
//        return savedSession
//    }
//    
//    class func loginController() -> UIAlertController {
//        let actions: [UIAlertAction] = [
//            UIAlertAction(title: LocalizedStringKey.cancel.localized, style: .cancel, handler: { _ in
//                SpotifyManager.logOut()
//            }),
//            UIAlertAction(title: LocalizedStringKey.spotifyOpenApp.localized, style: .default, handler: { _ in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                    SpotifyManager.authorize()
//                })
//            })
//        ]
//        
//        let model = AlertViewModel(title: "Spotify", message: LocalizedStringKey.spotifyAllowInAppMessage.localized, actions: actions, style: .alert)
//        let alert = AWAlertController.configure(with: model)
//        return alert
//    }
//}
