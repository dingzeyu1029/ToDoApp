//
//  Subtask.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

struct Subtask: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isChecked: Bool = false
}
