//
//  ToDoListApp.swift
//  ToDoListApp
//
//  Created by Dingze on 1/12/25.
//

import SwiftUI

@main
struct ToDoListApp: App {
    @StateObject private var userDataManager = UserDataManager(data: initializeUserData())
    @StateObject private var notificationManager = NotificationManager()
    
    // Monitor scene phase (active/inactive/background)
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(userDataManager)
                .onAppear {
                    notificationManager.requestAuthorization()
                    userDataManager.reScheduleAllNotifications()
                    
                    // Start observing time zone changes
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name.NSSystemTimeZoneDidChange,
                        object: nil,
                        queue: .main
                    ) { _ in
                        userDataManager.reScheduleAllNotifications()
                    }
                }
        }
        .onChange(of: scenePhase, initial: true) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                print("App became active")
                userDataManager.reScheduleAllNotifications()
            case .inactive:
                print("App is inactive")
            case .background:
                print("App is backgrounded")
            @unknown default:
                break
            }
        }
    }
}
