//
//  TaskViewModel.swift
//  ToDoListApp
//
//  Created by Dingze Yu on 3/8/25.
//

import SwiftUI
import Combine

final class TaskViewModel: ObservableObject {
    @Published var title: String
    @Published var taskDescription: String
    @Published var date: Date
    @Published var selectedTag: Tag
    @Published var subtasks: [Subtask]
    @Published var newSubtaskTitle: String = ""
    @Published var recurrence: RecurrenceFrequency
    
    // For editing existing task
    var editingTaskID: UUID?
    
    // MARK: - Initializers
    
    /// Initialize with default values for a new task
    init() {
        self.title = ""
        self.taskDescription = ""
        self.date = Date()
        self.selectedTag = Tag(name: "Default", color: "gray")
        self.subtasks = []
        self.recurrence = .none
        self.editingTaskID = nil
    }
    
    /// Initialize with values from an existing task for editing
    init(task: SingleCardData) {
        self.title = task.title
        self.taskDescription = task.taskDescription
        self.date = task.date
        self.selectedTag = task.tag
        self.subtasks = task.subtasks
        self.recurrence = task.recurrence
        self.editingTaskID = task.id
    }
    
    // MARK: - Task Validation
    
    /// Returns true if task has the minimum required data
    var isTaskValid: Bool {
        !title.isEmpty
    }
    
    // MARK: - Subtask Management
    
    /// Add a new subtask from the current input
    func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        
        withAnimation(.appDefault) {
            let newSubtask = Subtask(title: newSubtaskTitle)
            subtasks.append(newSubtask)
            newSubtaskTitle = ""
        }
    }
    
    /// Delete subtasks at specified indices
    func deleteSubtasks(at offsets: IndexSet) {
        withAnimation {
            subtasks.remove(atOffsets: offsets)
        }
    }
    
    /// Toggle a subtask's checked state
    func toggleSubtask(_ subtask: Subtask) {
        guard let index = subtasks.firstIndex(of: subtask) else { return }
        
        withAnimation {
            subtasks[index].isChecked.toggle()
        }
    }
    
    // MARK: - Task Saving
    
    /// Save the task to the user data manager
    func saveTask(to userData: UserDataManager, onCompletion: (() -> Void)? = nil) {
        if let id = editingTaskID {
            // Edit existing task
            let editedData = SingleCardData(
                title: title,
                taskDescription: taskDescription,
                date: date,
                tag: selectedTag,
                subtasks: subtasks,
                id: id,
                recurrence: recurrence
            )
            
            withAnimation(.appDefault) {
                userData.edit(id: id, data: editedData)
            }
        } else {
            // Add new task
            let newData = SingleCardData(
                title: title,
                taskDescription: taskDescription,
                date: date,
                tag: selectedTag,
                subtasks: subtasks,
                recurrence: recurrence
            )
            
            withAnimation(.appDefault) {
                userData.add(data: newData)
            }
        }
        
        userData.sort()
        onCompletion?()
    }
    
    // MARK: - Task Operations
    
    /// Reset the view model to default values
    func resetTask() {
        title = ""
        taskDescription = ""
        date = Date()
        selectedTag = Tag(name: "Default", color: "gray")
        subtasks = []
        recurrence = .none
        editingTaskID = nil
    }
}

// MARK: - Factory Methods
extension TaskViewModel {
    /// Creates a view model for a new task
    static func forNewTask() -> TaskViewModel {
        return TaskViewModel()
    }
    
    /// Creates a view model for editing an existing task
    static func forEditing(_ task: SingleCardData) -> TaskViewModel {
        return TaskViewModel(task: task)
    }
}
