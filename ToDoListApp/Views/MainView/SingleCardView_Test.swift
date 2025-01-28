//
//  SingleCardView_Test.swift
//  ToDoListApp
//
//  Created by Dingze on 1/27/25.
//

import SwiftUI

struct SingleCardView_Test: View {
    @EnvironmentObject var userDataManager: UserDataManager
    var itemID: UUID

    @Binding var multiSelectMode: Bool
    @Binding var selection: [UUID]

    @Environment(\.colorScheme) var colorScheme

    @State private var dragInProgress = false
    @State private var isExpanded = false
    @State private var offset: CGFloat = 0
    @State private var showDeleteButton = false
    @State private var navigateToEdit = false

    private let deleteButtonWidth: CGFloat = 80
    private let swipeThreshold: CGFloat = -60

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
                VStack() {
                    HStack {
                        // Tag color bar
                        colorBar(for: item.tag.color)

                        // Checkbox
                        Image(systemName: item.isChecked ? "checkmark.circle" : "circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.accent)
                            .onTapGesture {
                                userDataManager.check(id: itemID)
                                userDataManager.sort()
                            }
                            .padding(.leading, 5)

                        // Title and Date
                        Button {
                            if !dragInProgress && !multiSelectMode {
                                navigateToEdit = true
                            }
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
                        .buttonStyle(.plain)

                        // Expand subtasks icon
                        if !item.subtasks.isEmpty {
                            Button {
                                withAnimation(.easeInOut) {
                                    isExpanded.toggle()
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .rotationEffect(.degrees(isExpanded ? -90 : 0))
                                    .foregroundColor(.accent)
                                    .padding(.trailing, 15)
                            }
                        }
                    }
                    .frame(height: 70)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Handle multi-select
                        if multiSelectMode {
                            if isSelected {
                                selection.removeAll { $0 == itemID }
                            } else {
                                selection.append(itemID)
                            }
                        }
                    }
                    .background(
                        Color(uiColor: colorScheme == .light
                              ? .systemBackground
                              : .secondarySystemBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? .accent : .clear, lineWidth: 3)
                    )
                    .cornerRadius(10)
                    .shadow(radius: 10, x: 0, y: 8)

                    // Show subtasks if expanded
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(item.subtasks) { subtask in
                                HStack {
                                    // Subtask checkbox
                                    Image(systemName: subtask.isChecked ? "checkmark.circle" : "circle")
                                        .foregroundStyle(.accent)
                                        .onTapGesture {
                                            toggleSubtask(subtask, atIndex: index)
                                        }
                                    Text(subtask.title)
                                        .strikethrough(subtask.isChecked)
                                        .foregroundStyle(subtask.isChecked ? .secondary : .primary)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.leading, 25)
                        .padding(.top, 5)
                        .padding(.vertical, 10)
                    }
                }
                .offset(x: offset)
                .simultaneousGesture(swipeGesture)
            }
            .navigationDestination(isPresented: $navigateToEdit) {
                AddTaskView(editingData: item)
            }
        }
    }

    // MARK: - Drag Gesture

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

    // MARK: - Actions

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

    // MARK: - Color Bar

    @ViewBuilder
    private func colorBar(for color: String) -> some View {
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
