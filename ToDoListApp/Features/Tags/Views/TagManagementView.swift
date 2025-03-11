////
////  TagManagementView.swift
////  ToDoListApp
////
////  Created by Dingze Yu on 3/8/25.
////
//
//import SwiftUI
//
//struct TagManagementView: View {
//    @EnvironmentObject var userDataManager: UserDataManager
//    @Environment(\.dismiss) var dismiss
//    
//    @StateObject private var viewModel: TagViewModel
//    
//    init() {
//        // Will be initialized with the environment object in body
//        _viewModel = StateObject(wrappedValue: TagViewModel(userDataManager: UserDataManager()))
//    }
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                // Existing Tags Section
//                Section(header: Text("Existing Tags")) {
//                    if userDataManager.tags.isEmpty {
//                        Text("No tags available")
//                            .foregroundColor(.secondary)
//                            .italic()
//                    } else {
//                        ForEach(userDataManager.tags) { tag in
//                            TagRow(tag: tag, viewModel: viewModel)
//                        }
//                    }
//                }
//                
//                // Add New Tag Section
//                Section(header: Text("Add New Tag")) {
//                    TextField("Tag Name", text: $viewModel.newTagName)
//                        .autocapitalization(.words)
//                    
//                    Picker("Color", selection: $viewModel.newTagColor) {
//                        ForEach(viewModel.availableColors, id: \.self) { color in
//                            HStack {
//                                Circle()
//                                    .fill(viewModel.color(from: color))
//                                    .frame(width: 16, height: 16)
//                                    .padding(.trailing, 5)
//                                Text(color.capitalized)
//                            }
//                            .tag(color)
//                        }
//                    }
//                    
//                    Button("Add Tag") {
//                        viewModel.addNewTag()
//                    }
//                    .disabled(!viewModel.isNewTagValid)
//                }
//            }
//            .navigationTitle("Manage Tags")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                }
//            }
//            .alert("Delete Tag", isPresented: $viewModel.showDeleteAlert) {
//                Button("Cancel", role: .cancel) { }
//                Button("Delete", role: .destructive) {
//                    viewModel.confirmDeleteTag()
//                }
//            } message: {
//                Text("Tasks with this tag will be reassigned to the Default tag. This action cannot be undone.")
//            }
//            .onAppear {
//                // Update the view model with the proper userDataManager
//                viewModel.userDataManager = userDataManager
//            }
//        }
//    }
//}
//
//// MARK: - Tag Row Component
//struct TagRow: View {
//    let tag: Tag
//    @ObservedObject var viewModel: TagViewModel
//    
//    @State private var tagName: String
//    @State private var tagColor: String
//    
//    init(tag: Tag, viewModel: TagViewModel) {
//        self.tag = tag
//        self.viewModel = viewModel
//        _tagName = State(initialValue: tag.name)
//        _tagColor = State(initialValue: tag.color)
//    }
//    
//    var body: some View {
//        HStack {
//            // Color indicator
//            Circle()
//                .fill(viewModel.color(from: tagColor))
//                .frame(width: 16, height: 16)
//                .padding(.trailing, 5)
//            
//            // Tag name field
//            TextField("Tag Name", text: $tagName)
//                .onChange(of: tagName) { _, newValue in
//                    if !newValue.isEmpty && tagName != tag.name {
//                        viewModel.updateTagName(tag, newName: newValue)
//                    }
//                }
//            
//            // Color picker
//            Picker("", selection: $tagColor) {
//                ForEach(viewModel.availableColors, id: \.self) { color in
//                    Text(color.capitalized)
//                        .tag(color)
//                }
//            }
//            .pickerStyle(MenuPickerStyle())
//            .onChange(of: tagColor) { _, newValue in
//                viewModel.updateTagColor(tag, newColor: newValue)
//            }
//            
//            // Delete button
//            if viewModel.canDeleteTag(tag) {
//                Button {
//                    viewModel.deleteTag(tag)
//                } label: {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                }
//                .buttonStyle(BorderlessButtonStyle())
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    TagManagementView()
//        .environmentObject(UserDataManager.mock)
//}
