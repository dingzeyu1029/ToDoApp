//
//  AddTaskViewModel.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//


import SwiftUI
import Combine

final class AddTaskViewModel: ObservableObject {
    @Published var title: String
    @Published var taskDescription: String
    @Published var date: Date
    @Published var selectedTag: Tag
    @Published var subtasks: [Subtask]
    @Published var newSubtaskTitle: String = ""
    @Published var recurrence: RecurrenceFrequency
    
    // If editing an existing task, store the task ID
    var editingTaskID: UUID?

    init(title: String = "",
         taskDescription: String = "",
         date: Date = Date(),
         tag: Tag = Tag(name: "Default", color: "gray"),
         subtasks: [Subtask] = [],
         recurrence: RecurrenceFrequency = .none,
         editingTaskID: UUID? = nil)
    {
        self.title = title
        self.taskDescription = taskDescription
        self.date = date
        self.selectedTag = tag
        self.subtasks = subtasks
        self.recurrence = recurrence
        self.editingTaskID = editingTaskID
    }
    
    func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        let newSubtask = Subtask(title: newSubtaskTitle)
        subtasks.append(newSubtask)
        newSubtaskTitle = ""
    }
    
    func deleteSubtasks(at offsets: IndexSet) {
        subtasks.remove(atOffsets: offsets)
    }
    
    func saveTask(to userData: UserDataManager) {
        if let id = editingTaskID {
            // Edit existing
            let editedData = SingleCardData(
                title: title,
                taskDescription: taskDescription,
                date: date,
                tag: selectedTag,
                subtasks: subtasks,
                id: id,
                recurrence: recurrence
            )
            userData.edit(id: id, data: editedData)
        } else {
            // Add new
            let newData = SingleCardData(
                title: title,
                taskDescription: taskDescription,
                date: date,
                tag: selectedTag,
                subtasks: subtasks,
                recurrence: recurrence
            )
            userData.add(data: newData)
        }
    }
}
