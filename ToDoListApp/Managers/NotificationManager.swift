//
//  NotificationManager.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI
import UserNotifications

final class NotificationManager: NSObject, ObservableObject {
    
    override init() {
        super.init()
        // Optionally set self as the UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Request local notification authorization from the user
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    // Example: A method to schedule a single test notification (optional)
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test"
        content.body = "This is a test notification."
        
        // Trigger in 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification",
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule test notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Called when a user taps a notification in the background/foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("User tapped notification: \(response.notification.request.identifier)")
        // Navigate user or handle the tap
        completionHandler()
    }
    
    // Called if a notification arrives while the app is in the foreground (optional)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("Foreground notification: \(notification.request.identifier)")
        // If you want to show banner/sound while in foreground:
        completionHandler([.banner, .sound]) 
    }
}
