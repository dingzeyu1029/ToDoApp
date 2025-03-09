//
//  UserDataManager.swift
//  ToDoListApp
//
//  Created by Dingze on 1/12/25.
//

import Foundation
import UserNotifications
import SwiftUI

var encoder = JSONEncoder()

class UserDataManager: ObservableObject {
    @Published var ToDoList: [SingleCardData]
    @Published var tags: [Tag] = [
        Tag(name: "Default", color: "gray"),
        Tag(name: "Important", color: "red"),
        Tag(name: "School", color: "green"),
        Tag(name: "Work", color: "blue")
    ]

    init() {
        self.ToDoList = []
    }
    
    init(data: [SingleCardData]) {
        self.ToDoList = data
    }
    
    // Tag CRUD
    func addTag(_ tag: Tag) {
        tags.append(tag)
        self.storeData()
    }
    
    func editTag(_ oldTag: Tag, newTag: Tag) {
        if let index = tags.firstIndex(of: oldTag) {
            tags[index] = newTag
            self.storeData()
        }
    }
    
    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        
        for index in ToDoList.indices {
            if ToDoList[index].tag.id == tag.id {
                ToDoList[index].tag = tags[0]
            }
        }
        self.storeData()
    }
    
    // SingleCardData CRUD
    func add(data: SingleCardData) {
        self.ToDoList.append(data)
        self.storeData()
        self.sendNotification(id: data.id)
    }
    
    func check(id: UUID) {
        guard let index = ToDoList.firstIndex(where: { $0.id == id }) else {
            print("Error: Item with id \(id) not found.")
            return
        }
        
        ToDoList[index].isChecked.toggle()
        let item = ToDoList[index]
        storeData()
        
        if item.isChecked, item.recurrence != .none {
            if let newDate = nextRecurrenceDate(from: item.date, frequency: item.recurrence) {
                let newTask = SingleCardData(
                    title: item.title,
                    taskDescription: item.taskDescription,
                    date: newDate,
                    isChecked: false,
                    tag: item.tag,
                    subtasks: item.subtasks.map { subtask in
                        var resetSubtask = subtask
                        resetSubtask.isChecked = false
                        return resetSubtask
                    },
                    recurrence: item.recurrence
                )
                add(data: newTask)
            }
        }
        
        sort()
    }
    
    func delete(id: UUID) {
        if let index = ToDoList.firstIndex(where: { $0.id == id }) {
            let oldRequestIdentifier = "\(ToDoList[index].title)-\(ToDoList[index].id)"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [oldRequestIdentifier])
            ToDoList.remove(at: index)
            self.storeData()
        } else {
            print("Error: Item with id \(id) not found.")
        }
    }
    
    func edit(id: UUID, data: SingleCardData) {
        if let index = ToDoList.firstIndex(where: { $0.id == id }) {
            // Remove old request first
            let oldRequestIdentifier = "\(ToDoList[index].title)-\(ToDoList[index].id)"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [oldRequestIdentifier])
            
            // Now update the task
            self.ToDoList[index].title = data.title
            self.ToDoList[index].taskDescription = data.taskDescription
            self.ToDoList[index].date = data.date
            self.ToDoList[index].tag = data.tag
            self.ToDoList[index].subtasks = data.subtasks
            self.ToDoList[index].recurrence = data.recurrence
            
            // Save new changes
            self.storeData()
            
            // Then schedule the new one with the updated date
            self.sendNotification(id: id)
        } else {
            print("Error: Item with id \(id) not found.")
        }

    }
    
    // Subtask CRUD
    func addSubtask(to taskID: UUID, subtask: Subtask) {
        if let index = ToDoList.firstIndex(where: { $0.id == taskID }) {
            ToDoList[index].subtasks.append(subtask)
            storeData()
        }
    }

    func deleteSubtask(from taskID: UUID, subtaskID: UUID) {
        if let taskIndex = ToDoList.firstIndex(where: { $0.id == taskID }) {
            ToDoList[taskIndex].subtasks.removeAll { $0.id == subtaskID }
            storeData()
        }
    }
    
    // Store/Sort
    func sort() {
        withAnimation(.appDefault) {
            self.ToDoList.sort {
                if $0.isChecked != $1.isChecked {
                    return !$0.isChecked
                } else {
                    return $0.date < $1.date
                }
            }
        }
    }
    
    func storeData() {
        do {
            let storeData = try encoder.encode(self.ToDoList)
            UserDefaults.standard.set(storeData, forKey: "ToDoList")
        } catch {
            print("Failed to encode data: \(error.localizedDescription)")
        }
    }
    
    func nextRecurrenceDate(from date: Date, frequency: RecurrenceFrequency) -> Date? {
        guard frequency != .none else { return nil }
        
        var components = DateComponents()
        
        switch frequency {
        case .daily:
            components.day = 1
        case .weekly:
            components.day = 7
        case .monthly:
            components.month = 1
        case .none:
            return nil
        }
        
        return Calendar.current.date(byAdding: components, to: date)
    }
    
    // Notification Handling
    func sendNotification(id: UUID) {
        guard let index = ToDoList.firstIndex(where: { $0.id == id }) else {
            print("Error: Item with id \(id) not found.")
            return
        }
        
        // 1. Create a UNMutableNotificationContent.
        let notificationContent = UNMutableNotificationContent()
        
        // 2. Set the properties you need.
        notificationContent.title = ToDoList[index].title
        notificationContent.body = "Don't forget to complete this task!"
        
        // 3. Create the trigger — e.g., time interval or calendar-based.
        let interval = ToDoList[index].date.timeIntervalSinceNow
        if interval > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            
            // 4. Create the request with the mutable content and trigger.
            let requestIdentifier = "\(ToDoList[index].title)-\(ToDoList[index].id)"
            let request = UNNotificationRequest(identifier: requestIdentifier,
                                             content: notificationContent,
                                             trigger: trigger)
            
            // 5. Schedule the notification.
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Notification scheduling failed with error: \(error)")
                }
            }
        } else {
            print("The date/time is in the past. Notification not scheduled.")
        }
    }
}

// Filter logic
extension UserDataManager {
    func count(for filter: FilterType) -> Int {
        switch filter {
        case .all:
            return ToDoList.count
        case .dueToday:
            return ToDoList.filter {
                Calendar.current.isDateInToday($0.date)
            }.count
        case .comingUp:
            return ToDoList.filter { $0.date > Date() }.count
        case .completed:
            return ToDoList.filter { $0.isChecked }.count
        case .expired:
            return ToDoList.filter { $0.date < Date() && !$0.isChecked}.count
        }
    }
    
    func filterTasks(by filter: FilterType) -> [SingleCardData] {
        switch filter {
        case .all:
            return ToDoList
        case .dueToday:
            return ToDoList.filter { Calendar.current.isDateInToday($0.date) }
        case .comingUp:
            return ToDoList.filter { $0.date > Date() }
        case .completed:
            return ToDoList.filter { $0.isChecked }
        case .expired:
            return ToDoList.filter { $0.date < Date() && !$0.isChecked}
        }
    }
}

extension UserDataManager {
    static var mock: UserDataManager {
        let sampleData = [
            SingleCardData(
                title: "Team Meeting",
                taskDescription: "Discuss project updates and allocate tasks for next sprint.",
                date: Date().addingTimeInterval(3600), // 1 hour from now
                tag: Tag(name: "Work", color: "blue")
            ),
            SingleCardData(
                title: "Doctor Appointment",
                taskDescription: "Regular health check-up at Greenfield Clinic.",
                date: Date().addingTimeInterval(14400), // 4 hours from now
                tag: Tag(name: "Important", color: "red"),
                subtasks: [
                    Subtask(title: "Bring insurance card"),
                    Subtask(title: "Complete medical history form")
                ]
            ),
            SingleCardData(
                title: "Submit Expense Report",
                taskDescription: "Complete and send last month's expense report to Finance.",
                date: Date().addingTimeInterval(10800), // 3 hours from now
                tag: Tag(name: "Work", color: "blue")
            ),
            SingleCardData(
                title: "Birthday Party",
                taskDescription: "Attend John's birthday party at The Great Hall.",
                date: Date().addingTimeInterval(86400), // 24 hours from now
                tag: Tag(name: "Important", color: "red")
            ),
            SingleCardData(
                title: "Grocery Shopping",
                taskDescription: "Pick up essentials: milk, bread, eggs, and vegetables.",
                date: Date().addingTimeInterval(7200), // 2 hours from now
                tag: Tag(name: "Default", color: "gray")
            ),
            SingleCardData(
                title: "Project Deadline",
                taskDescription: "Finalize and submit the marketing campaign proposal.",
                date: Date().addingTimeInterval(43200), // 12 hours from now
                tag: Tag(name: "Important", color: "red")
            )
        ]
        let manager = UserDataManager(data: sampleData)
        return manager
    }
}

extension UserDataManager {
    
    // Re-schedule notifications for all tasks that are not completed and not in the past.
    func reScheduleAllNotifications() {
        // Clear all pending requests
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule new notifications for valid tasks
        for task in ToDoList {
            if !task.isChecked, task.date.timeIntervalSinceNow > 0 {
                sendNotification(id: task.id)
            }
        }
    }
}
