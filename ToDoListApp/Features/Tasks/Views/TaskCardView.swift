//
//  TaskCardView.swift
//  ToDoListApp
//
//  Created by Dingze Yu on 3/8/25.
//

import SwiftUI

struct TaskCardView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var isExpanded: Bool = false
    @State private var dragInProgress = false
    @State private var offset: CGFloat = 0
    @State private var showDeleteButton = false
    
    var itemID: UUID
    @Binding var multiSelectMode: Bool
    @Binding var selection: [UUID]
    
    private let deleteButtonWidth: CGFloat = 80
    private let swipeThreshold: CGFloat = -60
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if let index = userDataManager.ToDoList.firstIndex(where: { $0.id == itemID }) {
            let item = userDataManager.ToDoList[index]
            let isSelected = selection.contains(itemID)
            
            ZStack {
                // Delete button (only slides in on left swipe)
                if showDeleteButton || offset < 0 {
                    HStack {
                        Spacer()
                        Button {
                            deleteItem()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                        .padding(.trailing, 10)
                    }
                }

                // Main card content
                VStack {
                    // Header row with checkbox and title
                    HStack {
                        // Tag color bar
                        tagColorBar(for: item.tag.color)
                        
                        // Checkbox
                        Image(systemName: item.isChecked ? "checkmark.circle" : "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.accent)
                            .contentTransition(.symbolEffect(.replace))
                            .onTapGesture {
                                userDataManager.check(id: itemID)
                                userDataManager.sort()
                            }
                            .padding(.leading, 5)
                        
                        // Task info (title and date)
                        NavigationLink {
                            TaskDetailView(editingData: item)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundStyle(item.isChecked ? .secondary : .primary)
                                    .strikethrough(item.isChecked)
                                Text(DateFormatter.shared.string(for: item.date) ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                        }
                        .foregroundColor(.primary)
                        .disabled(multiSelectMode || dragInProgress)
                        
                        // Expand button (if has subtasks)
                        if !item.subtasks.isEmpty {
                            Button(action: {
                                withAnimation(.appDefault) {
                                    isExpanded.toggle()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.accent)
                                    .rotationEffect(.degrees(isExpanded ? -90 : 0))
                                    .padding(.trailing, 15)
                            }
                        }
                    }
                    .frame(height: 70)
                    .background(
                        Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? .accent : Color.clear, lineWidth: 3)
                    )
                    .animation(.appDefault, value: isSelected)
                    .cornerRadius(10)
                    //.shadow(radius: 10, x: 0, y: 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if multiSelectMode {
                            if isSelected {
                                selection.removeAll { $0 == itemID }
                            } else {
                                selection.append(itemID)
                            }
                        }
                    }
                    
                    // Subtasks list (shown when expanded)
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(item.subtasks) { subtask in
                                HStack {
                                    // Checkbox for Subtask
                                    Image(systemName: subtask.isChecked ? "checkmark.circle" : "circle")
                                        .foregroundStyle(.accent)
                                        .imageScale(.medium)
                                        .onTapGesture {
                                            toggleSubtask(subtask, atIndex: index)
                                        }
                                    
                                    // Subtask Title
                                    Text(subtask.title)
                                        .font(.body)
                                        .foregroundStyle(subtask.isChecked ? .secondary : .primary)
                                        .strikethrough(subtask.isChecked)
                                    Spacer()
                                }
                                .padding(.leading, 20)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .offset(x: offset)
                .simultaneousGesture(swipeGesture)
            }
        }
    }
    
    // MARK: - Swipe Gesture
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { gesture in
                // Skip if multi-select mode
                guard !multiSelectMode else { return }

                let horizontal = gesture.translation.width
                let vertical = gesture.translation.height

                // Only handle "mostly horizontal" drags
                if abs(horizontal) > abs(vertical) {
                    dragInProgress = true
                    // Only allow left swipe
                    if horizontal < 0 {
                        offset = horizontal
                        showDeleteButton = offset < swipeThreshold
                    }
                }
            }
            .onEnded { gesture in
                guard !multiSelectMode else { return }

                let horizontal = gesture.translation.width
                let vertical = gesture.translation.height

                if abs(horizontal) > abs(vertical), horizontal < 0 {
                    // If the card is swiped enough, snap to show delete
                    if offset < swipeThreshold {
                        withAnimation(.appDefault) {
                            offset = -deleteButtonWidth
                            showDeleteButton = true
                        }
                    } else {
                        resetPosition()
                    }
                } else {
                    resetPosition()
                }

                dragInProgress = false
            }
    }
    
    // MARK: - Helper Methods
    private func resetPosition() {
        withAnimation(.appDefault) {
            offset = 0
            showDeleteButton = false
        }
    }
    
    private func deleteItem() {
        withAnimation(.appDefault) {
            resetPosition()
            userDataManager.delete(id: itemID)
            selection.removeAll { $0 == itemID }
        }
    }
    
    private func toggleSubtask(_ subtask: Subtask, atIndex index: Int) {
        if let subIndex = userDataManager.ToDoList[index].subtasks.firstIndex(of: subtask) {
            userDataManager.ToDoList[index].subtasks[subIndex].isChecked.toggle()
            userDataManager.storeData()
        }
    }
    
    // MARK: - Tag Color Bar
    @ViewBuilder
    private func tagColorBar(for color: String) -> some View {
        let bar = Rectangle().frame(width: 8)
        switch color.lowercased() {
        case "blue": bar.foregroundColor(.blue)
        case "yellow": bar.foregroundColor(.yellow)
        case "red": bar.foregroundColor(.red)
        case "green": bar.foregroundColor(.green)
        default: bar.foregroundColor(.gray)
        }
    }
}
