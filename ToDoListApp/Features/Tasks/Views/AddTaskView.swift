//
//  AddTaskView.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userDataManager: UserDataManager
    
    @StateObject var viewModel: AddTaskViewModel
    
    @State var placeHolder:String = "Description"
    private let newTaskTitle = "New Task"
    private let editTaskTitle = "Edit Task"

    init(editingData: SingleCardData? = nil) {
        if let data = editingData {
            _viewModel = StateObject(wrappedValue: AddTaskViewModel(
                title: data.title,
                taskDescription: data.taskDescription,
                date: data.date,
                tag: data.tag,
                subtasks: data.subtasks,
                recurrence: data.recurrence,
                editingTaskID: data.id
            ))
        } else {
            _viewModel = StateObject(wrappedValue: AddTaskViewModel())
        }
    }
    
    var body: some View {
        Form {
            taskDetailsSection
            subtaskManagementSection
            actionButtonsSection
        }
    }
    
    // MARK: - View Components
    private var taskDetailsSection: some View {
        Section(header: Text(viewModel.editingTaskID == nil ? newTaskTitle : editTaskTitle)) {
            TextField("Task Name", text: $viewModel.title)
                .listRowSeparator(.hidden)
            
            ZStack(alignment: .topLeading) {
                if viewModel.taskDescription.isEmpty {
                    TextEditor(text: $placeHolder)
                        .foregroundStyle(.placeholder)
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
            
            DatePicker(selection: $viewModel.date, label: { Text("Date") })
                .listRowSeparator(.hidden)
            
            Picker("Repeat", selection: $viewModel.recurrence) {
                ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                    Text(freq.rawValue.capitalized).tag(freq)
                        .foregroundStyle(.secondary)
                }
            }
            .listRowSeparator(.hidden)
            
            NavigationLink(destination: TagPage(selectedTag: $viewModel.selectedTag)) {
                HStack {
                    Text("Tag")

                    Spacer()
                    
                    Text(viewModel.selectedTag.name)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var subtaskManagementSection: some View {
        Section(header: Text("Subtasks")) {
            // List of Existing Subtasks
            ForEach(viewModel.subtasks) { subtask in
                HStack {
                    Image(systemName: subtask.isChecked ? "checkmark.circle" : "circle")
                        .foregroundStyle(.accent)
                        .onTapGesture {
                            toggleSubtask(subtask)
                        }
                    
                    // Editable Subtask Title
                    TextField("Subtask Name", text: Binding(
                        get: { subtask.title },
                        set: { newTitle in
                            if let index = viewModel.subtasks.firstIndex(of: subtask) {
                                viewModel.subtasks[index].title = newTitle
                            }
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .onDelete(perform: viewModel.deleteSubtasks)
            
            // Add New Subtask Input
            HStack {
                TextField("New Subtask", text: $viewModel.newSubtaskTitle)
                
                Button(action: viewModel.addSubtask) {
                    Image(systemName: "plus.circle.fill")
                        //.foregroundStyle(.accent)
                }
                .disabled(viewModel.newSubtaskTitle.isEmpty)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        Section {
            Button(viewModel.editingTaskID == nil ? "Add" : "Confirm") {
                viewModel.saveTask(to: userDataManager)
                dismiss()
                userDataManager.sort()
            }
            Button("Cancel") { dismiss() }
        }
    }

    private func toggleSubtask(_ subtask: Subtask) {
        guard let idx = viewModel.subtasks.firstIndex(of: subtask) else { return }
        viewModel.subtasks[idx].isChecked.toggle()
    }
    
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
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddTaskView()
}
