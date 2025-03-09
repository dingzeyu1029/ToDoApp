//
//  TagPage.swift
//  ToDoListApp
//
//  Created by Dingze on 1/18/25.
//

import SwiftUI

struct TagPage: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Binding var selectedTag: Tag
    @Environment(\.dismiss) var dismiss
    
    @State private var isManagingTags: Bool = false
    
    var body: some View {
        VStack {
            List {
                ForEach(userDataManager.tags) { tag in
                    Button(action: { selectTag(tag) }) {
                        HStack {
                            Circle()
                                .fill(colorFromString(tag.color))
                                .frame(width: 8)
                                .padding(.trailing, 10)
                            
                            Text(tag.name)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if tag.id == selectedTag.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Tags")
            
            Spacer()
            
            HStack {
                Button("Manage Tags") {
                    isManagingTags = true
                }
                .padding(.top)
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .padding(.top)
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $isManagingTags) {
            ManageTags(userDataManager: userDataManager)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func selectTag(_ tag: Tag) {
        selectedTag = tag
        dismiss()
    }
}

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
    case "gray":
        return Color.gray
    default:
        return Color.gray
    }
}

struct ManageTags: View {
    @ObservedObject var userDataManager: UserDataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var newTagName: String = ""
    @State private var newTagColor: String = "blue"
    
    private let colors = ["red", "green", "blue", "yellow", "gray"]
    
    var body: some View {
        NavigationStack {
            Form {
                // Existing Tags Section
                Section(header: Text("Existing Tags")) {
                    ForEach(userDataManager.tags) { tag in
                        TagRow(tag: tag, userDataManager: userDataManager, colors: colors)
                    }
                    .onDelete(perform: deleteTag)
                }
                
                // Add New Tag Section
                Section(header: Text("Add New Tag")) {
                    TextField("Tag Name", text: $newTagName)
                        //.textFieldStyle(RoundedBorderTextFieldStyle())

                    Picker("Color", selection: $newTagColor) {
                        ForEach(colors, id: \.self) { color in
                            Text(color.capitalized).tag(color)
                        }
                    }
                    
                    Button("Add") {
                        addNewTag()
                    }
                    //.buttonStyle(.borderedProminent)
                    .disabled(newTagName.isEmpty) // Disable if no tag name is provided
                }
            }
            .navigationTitle("Manage Tags")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteTag(at offsets: IndexSet) {
        offsets.forEach { index in
            let tag = userDataManager.tags[index]
            userDataManager.deleteTag(tag)
        }
    }
    
    private func addNewTag() {
        let newTag = Tag(name: newTagName, color: newTagColor)
        userDataManager.addTag(newTag)
        newTagName = ""
        newTagColor = "blue"
    }
}

struct TagRow: View {
    let tag: Tag
    @ObservedObject var userDataManager: UserDataManager
    let colors: [String]

    var body: some View {
        HStack {
            Circle()
                .fill(colorFromString(tag.color))
                .frame(width: 10)
                .padding(.trailing, 10)

            TextField("Tag Name", text: Binding(
                get: { tag.name },
                set: { newName in
                    let updatedTag = Tag(id: tag.id, name: newName, color: tag.color)
                    userDataManager.editTag(tag, newTag: updatedTag)
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("", selection: Binding(
                get: { tag.color },
                set: { newColor in
                    let updatedTag = Tag(id: tag.id, name: tag.name, color: newColor)
                    userDataManager.editTag(tag, newTag: updatedTag)
                }
            )) {
                ForEach(colors, id: \.self) { color in
                    Text(color.capitalized).tag(color)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

#Preview {
    @Previewable @State var selectedTag = Tag(name: "Default", color: "gray")
    
    TagPage(selectedTag: $selectedTag)
        .environmentObject(UserDataManager.mock)
}
