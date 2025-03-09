//
//  TaskListView.swift
//  ToDoListApp
//
//  Created by Dingze on 1/21/25.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Binding var multiSelectMode: Bool
    @Binding var selection: [UUID]
    var filter: FilterType

    var body: some View {
        let tasks = userDataManager.filterTasks(by: filter)
        VStack {
            if tasks.isEmpty {
                Text("No tasks available.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            } else {
                ForEach(tasks) { item in
                    SingleCardView_Test(itemID: item.id,
                                        multiSelectMode: $multiSelectMode,
                                        selection: $selection)
                    .padding(.top)
                    .padding(.horizontal)
                }
                .transition(.slide)
            }
        }
        .animation(.appDefault, value: tasks) // Attach animation to the task list
    }
}
