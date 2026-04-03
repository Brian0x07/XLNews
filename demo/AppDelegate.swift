//
//  AppDelegate.swift
//  demo
//
//  React Native App Delegate - 驱动 RN 引擎
//

import UIKit
import SwiftUI
import RNViewFactory

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.overrideUserInterfaceStyle = .dark

        let swiftUIVC = UIHostingController(rootView: ContentView())
        swiftUIVC.title = "Discover"

        let nav = UINavigationController(rootViewController: swiftUIVC)

        // 暗色导航栏
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1) // #1C1C21
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.navigationBar.standardAppearance = navAppearance
        nav.navigationBar.scrollEdgeAppearance = navAppearance
        nav.navigationBar.tintColor = UIColor(red: 0.40, green: 0.56, blue: 1.0, alpha: 1) // #6690FF

        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()

        return true
    }
}
