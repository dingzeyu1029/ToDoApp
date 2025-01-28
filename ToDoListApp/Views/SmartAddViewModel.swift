//
//  SmartAddViewModel.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI
import Combine

final class SmartAddViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let gpt = AddTaskGPT()
    
    func processTask(in userDataManager: UserDataManager, dismissAction: @escaping () -> Void) {
        let tagList = userDataManager.tags.map { $0.name }
        
        gpt.fetchResponse(prompt: userInput, tags: tagList) { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let response = response else {
                    self.showAlert(message: "Failed to process your input. Please try again.")
                    return
                }
                
                // Parse response
                guard let taskName = response["task_name"] as? String,
                      let timeString = response["time"] as? String,
                      let subtasksArray = response["subtasks"] as? [String] else {
                    self.showAlert(message: "Task details are incomplete or invalid.")
                    return
                }
                
                // Convert date, parse description/tag, etc.
                let taskDate = self.parseDate(from: timeString) ?? Date()
                let description = response["description"] as? String ?? ""
                let tagName = response["tag"] as? String ?? "Default"
                let tag = userDataManager.tags.first { $0.name == tagName }
                       ?? Tag(name: tagName, color: "gray")
                
                // Convert subtasks
                let subtasks = subtasksArray.map { Subtask(title: $0) }
                
                // Add the new task
                let newTask = SingleCardData(
                    title: taskName,
                    taskDescription: description,
                    date: taskDate,
                    tag: tag,
                    subtasks: subtasks
                )
                
                withAnimation(.appDefault) {
                    userDataManager.add(data: newTask)
                }
                
                // Clear UI & dismiss
                self.userInput = ""
                dismissAction()
            }
        }
    }
    
    private func parseDate(from dateString: String) -> Date? {
        if let primary = DateFormatter.shared.date(from: dateString) {
            return primary
        }
        
        let fallbackFormats = ["MMM d, yyyy h:mm a", "yyyy-MM-dd HH:mm", "yyyy/MM/dd HH:mm"]
        for format in fallbackFormats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
    
    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
