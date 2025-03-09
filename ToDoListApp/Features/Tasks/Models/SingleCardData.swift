//
//  SingleCardData.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import Foundation

enum RecurrenceFrequency: String, Codable, CaseIterable, Equatable {
    case none
    case daily
    case weekly
    case monthly
}

struct SingleCardData: Identifiable, Codable, Equatable {
    var title: String
    var taskDescription: String
    var date: Date
    var isChecked: Bool = false
    var tag: Tag
    var subtasks: [Subtask] = []
    var id: UUID = UUID()
    var recurrence: RecurrenceFrequency = .none
}
