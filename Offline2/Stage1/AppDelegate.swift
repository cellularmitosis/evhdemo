//
//  AppDelegate.swift
//  Stage1
//
//  Created by Jason Pepas on 1/21/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        func configureUIKit() {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = navBarAppearance
        }
        configureUIKit()
        
        let window = UIWindow()
        self.window = window

        let api = URLSessionAPI()
//        let api = FailingAPI()

        let vc = PostsViewController(api: api)
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav

        window.makeKeyAndVisible()
        return true
    }
}
