//
//  TagViewModel.swift
//  ToDoListApp
//
//  Created by Dingze Yu on 3/8/25.
//

import SwiftUI
import Combine

final class TagViewModel: ObservableObject {
    @Published var newTagName: String = ""
    @Published var newTagColor: String = "blue"
    @Published var showDeleteAlert: Bool = false
    @Published var tagToDelete: Tag?
    
    private let userDataManager: UserDataManager
    
    // Available colors for tags
    let availableColors = ["red", "green", "blue", "yellow", "gray"]
    
    // MARK: - Initialization
    
    init(userDataManager: UserDataManager) {
        self.userDataManager = userDataManager
    }
    
    // MARK: - Tag Management
    
    /// Add a new tag with current name and color
    func addNewTag() {
        guard !newTagName.isEmpty else { return }
        
        let newTag = Tag(name: newTagName, color: newTagColor)
        
        withAnimation(.appDefault) {
            userDataManager.addTag(newTag)
        }
        
        // Reset input fields
        newTagName = ""
        newTagColor = "blue"
    }
    
    /// Delete a tag after confirmation
    func deleteTag(_ tag: Tag) {
        tagToDelete = tag
        showDeleteAlert = true
    }
    
    /// Confirm tag deletion
    func confirmDeleteTag() {
        guard let tag = tagToDelete else { return }
        
        withAnimation(.appDefault) {
            userDataManager.deleteTag(tag)
        }
        
        tagToDelete = nil
        showDeleteAlert = false
    }
    
    /// Update a tag's name
    func updateTagName(_ tag: Tag, newName: String) {
        guard !newName.isEmpty else { return }
        
        let updatedTag = Tag(id: tag.id, name: newName, color: tag.color)
        userDataManager.editTag(tag, newTag: updatedTag)
    }
    
    /// Update a tag's color
    func updateTagColor(_ tag: Tag, newColor: String) {
        let updatedTag = Tag(id: tag.id, name: tag.name, color: newColor)
        userDataManager.editTag(tag, newTag: updatedTag)
    }
    
    /// Check if a tag can be safely deleted
    func canDeleteTag(_ tag: Tag) -> Bool {
        // Don't allow deleting the last tag
        if userDataManager.tags.count <= 1 {
            return false
        }
        
        // Don't allow deleting Default tag
        if tag.name == "Default" {
            return false
        }
        
        return true
    }
    
    // MARK: - Validation
    
    /// Check if a tag name already exists (case-insensitive)
    func tagNameExists(_ name: String) -> Bool {
        return userDataManager.tags.contains { 
            $0.name.lowercased() == name.lowercased() 
        }
    }
    
    /// Check if the new tag is valid to add
    var isNewTagValid: Bool {
        !newTagName.isEmpty && !tagNameExists(newTagName)
    }
}

// Extension to support color utilities
extension TagViewModel {
    /// Get a SwiftUI Color from a color name string
    func color(from colorName: String) -> Color {
        switch colorName.lowercased() {
        case "red":
            return .red
        case "green":
            return .green
        case "blue":
            return .blue
        case "yellow":
            return .yellow
        default:
            return .gray
        }
    }
}
