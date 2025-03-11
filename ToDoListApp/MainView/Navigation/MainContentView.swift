//
//  MainContentView.swift
//  ToDoListApp
//
//  Created by Dingze on 1/12/25.
//

import SwiftUI

func initializeUserData() -> [SingleCardData] {
    let decoder = JSONDecoder()
    
    guard let storeData = UserDefaults.standard.data(forKey: "ToDoList") else {
        return []
    }
    
    do {
        let decoded = try decoder.decode([SingleCardData].self, from: storeData)
        return decoded
    } catch {
        print("Failed to decode with error: \(error.localizedDescription)")
        return []
    }
}

struct MainContentView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @StateObject private var highlightsManager = TaskHighlightsManager()
    
    // MARK: - State for new menu-based filtering
    @State private var filter: FilterType = .all
    @State private var showAddToDoPage: Bool = false
    @State private var showGPTSheet: Bool = false
    @State private var showMenu: Bool = false
    @State private var selection: [UUID] = []
    @State private var multiSelectMode: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                ScrollView {
                    LazyVStack {
//                            TaskHighlightsView(highlightsManager: highlightsManager)
//                                .padding(.top, 10)
                        
//                            if filter != .completed && filter != .expired {
//                                CircularProgressView(filter: $filter,
//                                                     percent: calculateProgress())
//                                .padding()
//                            }
                        
                        TaskListView(
                            multiSelectMode: $multiSelectMode,
                            selection: $selection,
                            filter: filter
                        )
                    }
                }
                .refreshable {
                    await refreshHighlights()
                }
                ActionButtonsView(showAddToDoPage: $showAddToDoPage,
                                  showGPTSheet: $showGPTSheet,
                                  multiSelectMode: $multiSelectMode,
                                  selection: $selection
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MenuButton(filter: $filter,
                               showMenu: $showMenu)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack {
                        DeleteButton(selection: $selection)
                        .opacity(multiSelectMode ? 1 : 0)
                        
                        SelectAllButton(selection: $selection)
                        .opacity(multiSelectMode ? 1 : 0)
                        
                        MultiSelectButton(multiSelectMode: $multiSelectMode,
                                          selection: $selection)
                    }
                }
            }
            .toolbarBackgroundVisibility(.visible)
            .navigationTitle(filter.rawValue)
        }
        
        if showMenu {
            MenuPage(selectedFilter: $filter,
                     showMenu: $showMenu)
            .transition(.move(edge: .leading))
            .zIndex(2.0)
        }
    }
    
    private func calculateProgress() -> Double {
        let filteredTasks = userDataManager.filterTasks(by: filter)
        let completedTasks = filteredTasks.filter { $0.isChecked }
        return filteredTasks.isEmpty ? 0 : Double(completedTasks.count) / Double(filteredTasks.count)
    }
    
    private func refreshHighlights() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await highlightsManager.loadAIHighlights(from: userDataManager.ToDoList)
    }
}

struct EditContainerView<Content: View>: View {
    @Binding var editingMode: Bool
    let content: () -> Content
    
    var body: some View {
        content()
            .onDisappear {
                editingMode = false
            }
    }
}

#Preview {
    MainContentView()
        .environmentObject(UserDataManager.mock)
}
