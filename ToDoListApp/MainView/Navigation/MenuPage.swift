//
//  MenuPage.swift
//  ToDoListApp
//
//  Created by Dingze on 1/13/25.
//

import SwiftUI

struct MenuPage: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Binding var selectedFilter: FilterType
    @Binding var showMenu: Bool
    
    var body: some View {
        Form {
            Section {
                filterButtons
            }
            
//            Section {
//                settingsButton
//            }
        }
    }
    
    // MARK: - Filter Buttons
    private var filterButtons: some View {
        Group {
            menuButton(filter: .all, icon: "list.bullet")
            menuButton(filter: .dueToday, icon: "calendar") 
            menuButton(filter: .comingUp, icon: "clock")
            menuButton(filter: .completed, icon: "checkmark.square")
            menuButton(filter: .expired, icon: "exclamationmark.square")
        }
    }
    
    // MARK: - Settings Button
    private var settingsButton: some View {
        Button(action: {}) {
            SettingsRow(iconName: "gear",
                        title: "Settings",
                        badge: nil)
        }
    }
    
    // MARK: - Helper Methods
    private func menuButton(filter: FilterType, icon: String) -> some View {
        Button(action: {
            selectedFilter = filter
            withAnimation(.appDefault) {
                showMenu.toggle()
            }
        }) {
            SettingsRow(iconName: icon,
                        title: filter.rawValue,
                        badge: "\(userDataManager.count(for: filter))")
        }
    }
}

struct SettingsRow: View {
    let iconName: String
    let title: String
    let badge: String?
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.primary)
                .padding(.trailing, 10)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let badge = badge {
                Text(badge)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    MenuPage(
        selectedFilter: .constant(.all),
        showMenu: .constant(true)
    )
    .environmentObject(UserDataManager.mock)
}
