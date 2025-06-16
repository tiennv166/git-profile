//
//  GitProfileApp.swift
//  GitProfile
//
//  Created by Tien Nguyen on 13/6/25.
//

import LanguageManager_iOS
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        LanguageManager.shared.defaultLanguage = .en
        return true
    }
}

@main
struct GitProfileApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
