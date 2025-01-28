//
//  DeleteButton.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

struct DeleteButton: View {
    @Binding var selection: [UUID]
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var showAlert: Bool = false // State to show the alert
    
    var body: some View {
        Button {
            showAlert = true;
        } label: {
            Image(systemName: "trash")
                .foregroundStyle(.accent)
        }
        .alert("Delete Selected Tasks", isPresented: $showAlert) {
            Button("Confirm", role: .destructive) {
                withAnimation(.appDefault) {
                    for item in selection {
                        userDataManager.delete(id: item)
                    }
                    selection.removeAll()
                }
            }
            Button("Cancel", role: .cancel) {
                // Dismiss alert without action
            }
        } message: {
            Text("Are you sure you want to delete the selected tasks? This action cannot be undone.")
        }
    }
}
