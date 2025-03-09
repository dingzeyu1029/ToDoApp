//
//  SingleCardView.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

struct SingleCardView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Namespace private var namespace
    @State private var isExpanded: Bool = false
    @State var offset: CGFloat = 0
    
    var itemID: UUID

    @Binding var multiSelectMode: Bool
    @Binding var selection: [UUID]
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if let index = userDataManager.ToDoList.firstIndex(where: { $0.id == itemID }) {
            let item = userDataManager.ToDoList[index]
            let isSelected = selection.contains(itemID)
            
            VStack {
                HStack {
                    // Left color bar
                    colorBar(for: item.tag.color)
                    
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
                    
                    NavigationLink {
                        AddTaskView(editingData: item)
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(item.isChecked ? .secondary : .primary)
                                .strikethrough(item.isChecked)
                            Text(DateFormatter.shared.string(for: item.date)!)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .foregroundColor(.primary)
                    .disabled(multiSelectMode)
                    
                    Spacer()
                    
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
                                .foregroundColor(.accent)
                                .rotationEffect(.degrees(isExpanded ? -90 : 0))
                                .padding(.trailing, 15)
                        }
                    }
                }
                .frame(height: 70)
                .background(
                    Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground) // Adaptive background
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? .accent : Color.clear, lineWidth: 3)
                )
                .animation(.appDefault, value: isSelected)
                .cornerRadius(10)
                .shadow(radius: 10, x: 0, y: 8)
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
                // Subtasks List (Shown when expanded)
                if isExpanded {
                    VStack(alignment: .leading, spacing: 5) {
                         ForEach(item.subtasks) { subtask in
                             HStack {
                                 // Checkbox for Subtask
                                 Image(systemName: subtask.isChecked ? "checkmark.circle" : "circle")
                                     .foregroundStyle(.accent)
                                     .imageScale(.medium)
                                     .onTapGesture {
                                         if let subtaskIndex = userDataManager.ToDoList[index].subtasks.firstIndex(of: subtask) {
                                             userDataManager.ToDoList[index].subtasks[subtaskIndex].isChecked.toggle()
                                             userDataManager.storeData()
                                         }
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
        }
    }

    // MARK: - Helper for color bar
    @ViewBuilder
    private func colorBar(for color: String) -> some View {
        switch color {
        case "blue":
            Rectangle().frame(width: 8).foregroundStyle(.blue)
        case "yellow":
            Rectangle().frame(width: 8).foregroundStyle(.yellow)
        case "red":
            Rectangle().frame(width: 8).foregroundStyle(.red)
        case "green":
            Rectangle().frame(width: 8).foregroundStyle(.green)
        default:
            Rectangle().frame(width: 8).foregroundStyle(.gray)
        }
    }
}
