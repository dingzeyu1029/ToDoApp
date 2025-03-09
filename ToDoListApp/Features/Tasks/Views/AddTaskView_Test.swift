//
//  AddToDo.swift
//  ToDoListApp
//
//  Created by Dingze on 1/13/25.
//

import SwiftUI

struct AddTaskView_Test: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State var title: String = ""
    @State var taskDescription: String = ""
    @State var placeHolder: String = "Description"
    @State var date: Date = Date()
    @State var selectedTag: Tag = Tag(name: "Default", color: "gray")
    @State var subtasks: [Subtask] = []
    @State private var newSubtaskTitle: String = ""
    
    private var tags: [Tag] {
        userDataManager.tags
    }
    
    // MARK: - Constants
    var id: UUID? = nil
    var isEditing: Bool = false
    
    private let newTaskTitle = "New Task"
    private let editTaskTitle = "Edit Task"
    private let addText = "Add"
    private let confirmText = "Confirm"
    
    // MARK: - Body
    var body: some View {
        Form {
            taskDetailsSection
            subtaskManagementSection
            actionButtonsSection
        }
    }
    
    // MARK: - View Components
    private var taskDetailsSection: some View {
        Section(header: Text(isEditing ? editTaskTitle : newTaskTitle)) {
            TextField("Task Name", text: self.$title)
                .listRowSeparator(.hidden)
            
            ZStack(alignment: .topLeading) {
                if self.taskDescription.isEmpty {
                    TextEditor(text: $placeHolder)
                        .foregroundStyle(.placeholder)
                }
                TextEditor(text: self.$taskDescription)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary, lineWidth: 0.3)
                    )
            }
            .padding(.bottom, 8)
            .listRowSeparator(.hidden)
            
            DatePicker(selection: self.$date, label: { Text("Date") })
                .listRowSeparator(.hidden)
            
            NavigationLink(destination: TagPage(selectedTag: $selectedTag)) {
                HStack {
                    Text("Tag")

                    Spacer()
                    
                    Text(selectedTag.name)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var subtaskManagementSection: some View {
        Section(header: Text("Subtasks")) {
            // List of Existing Subtasks
            ForEach(self.subtasks) { subtask in
                HStack {
                    Image(systemName: subtask.isChecked ? "checkmark.circle" : "circle")
                        .foregroundStyle(.accent)
                        .onTapGesture {
                            if let index = subtasks.firstIndex(of: subtask) {
                                subtasks[index].isChecked.toggle()
                            }
                        }
                    
                    // Editable Subtask Title
                    TextField("Subtask Name", text: Binding(
                        get: { subtask.title },
                        set: { newTitle in
                            if let index = subtasks.firstIndex(of: subtask) {
                                subtasks[index].title = newTitle
                            }
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .onDelete(perform: deleteSubtask)
            
            // Add New Subtask Input
            HStack {
                TextField("New Subtask", text: $newSubtaskTitle)
                
                Button(action: addSubtask) {
                    Image(systemName: "plus.circle.fill")
                        //.foregroundStyle(.accent)
                }
                .disabled(newSubtaskTitle.isEmpty)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        Section {
            Button(action: saveTask) {
                Text(isEditing ? confirmText : addText)
            }
            
            Button(action: dismiss) {
                Text("Cancel")
            }
        }
    }
    
    private func addSubtask() {
        let newSubtask = Subtask(title: newSubtaskTitle)
        subtasks.append(newSubtask)
        newSubtaskTitle = "" // Clear input field
    }

    private func deleteSubtask(at offsets: IndexSet) {
        subtasks.remove(atOffsets: offsets)
    }
    
    // MARK: - Actions
    private func saveTask() {
        if self.id == nil {
            userDataManager.add(data: SingleCardData(title: self.title,
                                              taskDescription: self.taskDescription,
                                              date: self.date,
                                              tag: self.selectedTag,
                                              subtasks: self.subtasks))
        } else {
            userDataManager.edit(id: self.id!,
                          data: SingleCardData(title: self.title,
                                               taskDescription: self.taskDescription,
                                               date: self.date,
                                               tag: self.selectedTag,
                                               subtasks: self.subtasks))
        }
        dismiss()
        userDataManager.sort()
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview
#Preview {
    AddTaskView()
}
