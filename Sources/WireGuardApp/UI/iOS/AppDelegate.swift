// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import os.log
import ProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainVC: MainViewController?
    var isLaunchedForSpecificAction = false

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.configureGlobal(tagged: "APP", withFilePath: FileManager.logFileURL?.path)

        if let launchOptions = launchOptions {
            if launchOptions[.url] != nil || launchOptions[.shortcutItem] != nil {
                isLaunchedForSpecificAction = true
            }
        }

//        NotificationCenter.default.addObserver(self, selector: #selector(openChooseVCForLogin), name: .needOpenChooseVCForLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openAuth), name: .needOpenAuth, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openMainTabBar), name: .needOpenMainTabBar, object: nil)

        ProgressHUD.animationType = .circleArcDotSpin

        if UserDefaultsManager.shared.isFirstOpeningApp {
            self.openVCAsRoot(vc: AuthVC.self)
        } else if KeychainManager.shared.authToken != nil {
            self.openVCAsRoot(vc: MainTabBar.self)
        } else {
            self.openVCAsRoot(vc: ChooseVC.self)
        }

//        let window = UIWindow(frame: UIScreen.main.bounds)
//        self.window = window
//
//        let mainVC = MainViewController()
//        window.rootViewController = mainVC
//        window.makeKeyAndVisible()
//
//        self.mainVC = mainVC


//        self.openVCAsRoot(vc: HomeVC.self)

        return true
    }

    func openVCAsRoot(vc: UIViewController.Type) {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: vc.className)
        if self.window?.rootViewController?.className != vc.className {
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
    }

//    @objc
//    func openChooseVCForLogin() {
//        guard let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: ChooseVC.className) as? ChooseVC else { return }
//        vc.openLogin = true
//        if self.window?.rootViewController?.className != vc.className {
//            self.window?.rootViewController = vc
//            self.window?.makeKeyAndVisible()
//        }
//    }

    @objc
    func openMainTabBar() {
        self.openVCAsRoot(vc: MainTabBar.self)
    }

    @objc
    func openAuth() {
        self.openVCAsRoot(vc: AuthVC.self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        mainVC?.importFromDisposableFile(url: url)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        mainVC?.refreshTunnelConnectionStatuses()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        guard let allTunnelNames = mainVC?.allTunnelNames() else { return }
        application.shortcutItems = QuickActionItem.createItems(allTunnelNames: allTunnelNames)
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard shortcutItem.type == QuickActionItem.type else {
            completionHandler(false)
            return
        }
        let tunnelName = shortcutItem.localizedTitle
        mainVC?.showTunnelDetailForTunnel(named: tunnelName, animated: false, shouldToggleStatus: true)
        completionHandler(true)
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return !self.isLaunchedForSpecificAction
    }

    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        guard let vcIdentifier = identifierComponents.last else { return nil }
        if vcIdentifier.hasPrefix("TunnelDetailVC:") {
            let tunnelName = String(vcIdentifier.suffix(vcIdentifier.count - "TunnelDetailVC:".count))
            if let tunnelsManager = mainVC?.tunnelsManager {
                if let tunnel = tunnelsManager.tunnel(named: tunnelName) {
                    return TunnelDetailTableViewController(tunnelsManager: tunnelsManager, tunnel: tunnel)
                }
            } else {
                // Show it when tunnelsManager is available
                mainVC?.showTunnelDetailForTunnel(named: tunnelName, animated: false, shouldToggleStatus: false)
            }
        }
        return nil
    }
}
