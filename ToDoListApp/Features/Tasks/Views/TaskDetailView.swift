//
//  TaskDetailView.swift
//  ToDoListApp
//
//  Created by Dingze on 3/8/25.
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userDataManager: UserDataManager
    
    @StateObject private var viewModel: TaskViewModel
    
    @State private var placeHolder: String = "Description"
    
    // MARK: - Initializer
    init(editingData: SingleCardData? = nil) {
        if let data = editingData {
            _viewModel = StateObject(wrappedValue: TaskViewModel.forEditing(data))
        } else {
            _viewModel = StateObject(wrappedValue: TaskViewModel.forNewTask())
        }
    }
    
    // MARK: - Body
    var body: some View {
        Form {
            taskDetailsSection
            subtaskManagementSection
            actionButtonsSection
        }
    }
    
    // MARK: - View Components
    
    /// Main task details (title, description, date, etc)
    private var taskDetailsSection: some View {
        Section(header: Text("New Task")) {
            // Task Title
            TextField("Task Name", text: $viewModel.title)
                .listRowSeparator(.hidden)
            
            // Task Description
            ZStack(alignment: .topLeading) {
                if viewModel.taskDescription.isEmpty {
                    TextEditor(text: $placeHolder)
                        .foregroundStyle(.placeholder)
                        .disabled(true)
                }
                TextEditor(text: $viewModel.taskDescription)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary, lineWidth: 0.3)
                    )
            }
            .padding(.bottom, 8)
            .listRowSeparator(.hidden)
            
            // Due Date
            DatePicker(selection: $viewModel.date, label: { Text("Date") })
                .listRowSeparator(.hidden)
            
            // Recurrence
            Picker("Repeat", selection: $viewModel.recurrence) {
                ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                    Text(freq.rawValue.capitalized).tag(freq)
                        .foregroundStyle(.secondary)
                }
            }
            .listRowSeparator(.hidden)
            
            // Tag Selection
            NavigationLink(destination: TagPage(selectedTag: $viewModel.selectedTag)) {
                HStack {
                    Text("Tag")
                    
                    Spacer()
                    
                    HStack {
                        Circle()
                            .fill(colorFromString(viewModel.selectedTag.color))
                            .frame(width: 10, height: 10)
                            .padding(.trailing, 4)
                        
                        Text(viewModel.selectedTag.name)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    /// Subtasks management section
    private var subtaskManagementSection: some View {
        Section(header: Text("Subtasks")) {
            // List of Existing Subtasks
            ForEach(viewModel.subtasks) { subtask in
                HStack {
                    // Checkbox
                    Image(systemName: subtask.isChecked ? "checkmark.circle" : "circle")
                        .foregroundStyle(.accent)
                        .onTapGesture {
                            viewModel.toggleSubtask(subtask)
                        }
                    
                    // Editable Subtask Title
                    TextField("Subtask Name", text: binding(for: subtask))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .contentShape(Rectangle())
            }
            .onDelete(perform: viewModel.deleteSubtasks)
            
            // Add New Subtask Input
            HStack {
                TextField("New Subtask", text: $viewModel.newSubtaskTitle)
                
                Button(action: viewModel.addSubtask) {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(viewModel.newSubtaskTitle.isEmpty)
            }
        }
    }
    
    /// Action buttons (save/cancel)
    private var actionButtonsSection: some View {
        Section {
            Button(viewModel.editingTaskID == nil ? "Add Task" : "Save Changes") {
                viewModel.saveTask(to: userDataManager) {
                    dismiss()
                }
            }
            .disabled(!viewModel.isTaskValid)
            
            Button("Cancel", role: .cancel) { 
                dismiss()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Create a binding for a specific subtask's title
    private func binding(for subtask: Subtask) -> Binding<String> {
        Binding(
            get: { subtask.title },
            set: { newVal in
                if let idx = viewModel.subtasks.firstIndex(of: subtask) {
                    viewModel.subtasks[idx].title = newVal
                }
            }
        )
    }
    
    /// Dismiss the view
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Helper function for tag colors
func colorFromString(_ colorName: String) -> Color {
    switch colorName.lowercased() {
    case "red":
        return Color.red
    case "green":
        return Color.green
    case "blue":
        return Color.blue
    case "yellow":
        return Color.yellow
    default:
        return Color.gray
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        TaskDetailView()
            .environmentObject(UserDataManager.mock)
    }
}
