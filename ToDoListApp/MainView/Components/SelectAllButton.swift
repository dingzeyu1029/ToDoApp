//
//  SelectAllButton.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

struct SelectAllButton: View {
    @Binding var selection: [UUID]
    @EnvironmentObject var userDataManager: UserDataManager
    
    var body: some View {
        Button(action: {
            withAnimation(.appDefault) {
                if selection.count == userDataManager.ToDoList.count {
                    // Deselect all if everything is already selected
                    selection.removeAll()
                } else {
                    // Select all tasks
                    selection = userDataManager.ToDoList.map { $0.id }
                }
            }
        }) {
            Image(systemName: "checklist.checked")
                .foregroundStyle(.accent)
        }
    }
}
