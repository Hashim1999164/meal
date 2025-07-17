//
//  MealApp.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//

//
//  MealMoodApp.swift
//  MealMood
//
//  Created by shh on 18/05/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct MealApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var dataSyncService = DataSyncService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(healthKitManager)
                .environmentObject(dataSyncService)
                .preferredColorScheme(.dark)
                .onAppear {
                    healthKitManager.requestAuthorization()
                    dataSyncService.initialize()
                }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let settings = db.settings
        
        settings.cacheSettings = MemoryCacheSettings()
        db.settings = settings
        return true
    }
}
