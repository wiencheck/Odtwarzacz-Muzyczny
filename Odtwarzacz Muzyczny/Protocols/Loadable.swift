////
////  Loadable.swift
////  Plum
////
////  Created by Adam Wienconek on 11.07.2019.
////  Copyright © 2019 adam.wienconek. All rights reserved.
////
//
//import JGProgressHUD
//
//protocol Loadable {
//    func loadingDidBegin()
//    func loadingDidBegin(message: String?)
//    func loadingDidEnd()
//    func loadingDidEnd(error: Error?)
//}
//
//extension Loadable where Self: UIViewController {
//    func loadingDidBegin() {
//        let hud = JGProgressHUD(style: .automatic)
//        hud.backgroundColor = Theme.dimColor
//        hud.showInRootController()
//        //hud.show(in: view)
//    }
//    
//    func loadingDidBegin(message: String?) {
//        let hud = JGProgressHUD(style: .automatic)
//        hud.textLabel.text = message
//        hud.backgroundColor = Theme.dimColor
//        hud.showInRootController()
//        //hud.show(in: view)
//    }
//    
//    func loadingDidEnd() {
////        guard let hud = view.subviews.first(where: { $0 is JGProgressHUD }) as? JGProgressHUD else {
////            return
////        }
//        guard let hud = UIApplication.shared.keyWindow?.rootViewController?.view.subviews.first(where: { $0 is JGProgressHUD }) as? JGProgressHUD else {
//            return
//        }
//        hud.dismiss()
//    }
//    
//    func loadingDidEnd(error: Error?) {
////        guard let hud = view.subviews.first(where: { $0 is JGProgressHUD }) as? JGProgressHUD else {
////            return
////        }
//        guard let hud = UIApplication.shared.keyWindow?.rootViewController?.view.subviews.first(where: { $0 is JGProgressHUD }) as? JGProgressHUD else {
//            return
//        }
//        guard let error = error else {
//            hud.dismiss()
//            return
//        }
//        hud.indicatorView = JGProgressHUDErrorIndicatorView()
//        hud.textLabel.text = error.localizedDescription
//        hud.dismiss(afterDelay: 4)
//    }
//}
//
//protocol Alertable {
//    func didReceiveAlert(model: AlertViewModel)
//}
//
//extension Alertable where Self: UIViewController {
//    func didReceiveAlert(model: AlertViewModel) {
//        DispatchQueue.main.async {
//            AWAlertController.configure(with: model).show()
//            //self.present(AWAlertController.configure(with: model), animated: true, completion: nil)
//        }
//    }
//}
//
//protocol Errorable {
//    func didReceiveMessage(_ message: AWMessage)
//    func didEncounterError(_ error: Error)
//}
//
//extension Errorable where Self: UIViewController {
//    func didReceiveMessage(_ message: AWMessage) {
//        let model = AlertViewModel(message: message)
//        DispatchQueue.main.async {
//            self.present(AWAlertController.configure(with: model), animated: true, completion: nil)
//        }
//    }
//    
//    func didEncounterError(_ error: Error) {
//        let message = AWMessage(with: error)
//        let model = AlertViewModel(message: message)
//        DispatchQueue.main.async {
//            self.present(AWAlertController.configure(with: model), animated: true, completion: nil)
//        }
//    }
//}
//
//extension JGProgressHUDStyle {
//    static var automatic: JGProgressHUDStyle {
//        return Theme.isDark ? .dark : .light
//    }
//}
//
//extension JGProgressHUD {
//    func showInRootController() {
//        guard let rootView = UIApplication.shared.keyWindow?.rootViewController?.view else { return }
//        show(in: rootView)
//    }
//}
