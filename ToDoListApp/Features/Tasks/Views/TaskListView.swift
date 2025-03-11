//
//  TaskListView.swift
//  ToDoListApp
//
//  Created by Dingze Yu on 3/8/25.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Binding var multiSelectMode: Bool
    @Binding var selection: [UUID]
    var filter: FilterType
    
    // Optional search text binding for filtering
    var searchText: String = ""
    
    var body: some View {
        let tasks = filteredTasks
        
        VStack() {
            if tasks.isEmpty {
                emptyStateView
            } else {
                ForEach(tasks) { task in
                    TaskCardView(
                        itemID: task.id,
                        multiSelectMode: $multiSelectMode,
                        selection: $selection
                    )
                }
                .padding(.horizontal)
                .padding(.top)
                .transition(.slide)
            }
        }
        .animation(.appDefault, value: tasks)
    }
    
    // MARK: - Computed Properties
    
    /// Tasks filtered by the current filter type and search text
    private var filteredTasks: [SingleCardData] {
        var tasks = userDataManager.filterTasks(by: filter)
        
        // Apply search filtering if search text is not empty
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.taskDescription.localizedCaseInsensitiveContains(searchText) ||
                task.tag.name.localizedCaseInsensitiveContains(searchText) ||
                task.subtasks.contains { $0.title.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return tasks
    }
    
    // MARK: - View Components
    
    /// Empty state view when no tasks match the current filter
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            Text(emptyStateTitle)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 60)
        .padding(.bottom, 100)
    }
    
    /// Icon for the empty state view based on filter type
    private var emptyStateIcon: String {
        switch filter {
        case .all:
            return "list.bullet.clipboard"
        case .dueToday:
            return "calendar"
        case .comingUp:
            return "clock"
        case .completed:
            return "checkmark.circle"
        case .expired:
            return "exclamationmark.triangle"
        }
    }
    
    /// Title for the empty state view based on filter type
    private var emptyStateTitle: String {
        switch filter {
        case .all:
            return "No Tasks Yet"
        case .dueToday:
            return "Nothing Due Today"
        case .comingUp:
            return "No Upcoming Tasks"
        case .completed:
            return "No Completed Tasks"
        case .expired:
            return "No Overdue Tasks"
        }
    }
    
    /// Message for the empty state view based on filter type
    private var emptyStateMessage: String {
        switch filter {
        case .all:
            return "Tap the 'New Task' button to create your first task."
        case .dueToday:
            return "You're all caught up! Nothing is scheduled for today."
        case .comingUp:
            return "No tasks scheduled for the future. Add one using the 'New Task' button."
        case .completed:
            return "Complete some tasks to see them here."
        case .expired:
            return "You're on top of things! No tasks are overdue."
        }
    }
}
