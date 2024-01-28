//
//  JoinACodeApp.swift
//  JoinACode
//
//  Created by Ostap Artym on 26.01.2024.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct JoinACodeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if logStatus {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}

