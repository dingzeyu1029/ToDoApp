//
//  FilterType.swift
//  ToDoListApp
//
//  Created by Dingze on 3/8/25.
//

import Foundation

/// Defines the different ways to filter tasks in the app
enum FilterType: String, CaseIterable, Identifiable {
    case all = "All Tasks"
    case dueToday = "Due Today"
    case comingUp = "Coming Up"
    case completed = "Completed"
    case expired = "Expired"
    
    var id: String { self.rawValue }
    
    /// Returns a system image name appropriate for this filter type
    var iconName: String {
        switch self {
        case .all:
            return "list.bullet"
        case .dueToday:
            return "calendar"
        case .comingUp:
            return "clock"
        case .completed:
            return "checkmark.square"
        case .expired:
            return "exclamationmark.square"
        }
    }
    
    /// Returns a descriptive label for this filter type
    var description: String {
        switch self {
        case .all:
            return "View all your tasks"
        case .dueToday:
            return "Tasks due today"
        case .comingUp:
            return "Upcoming tasks"
        case .completed:
            return "Completed tasks"
        case .expired:
            return "Overdue tasks"
        }
    }
}
