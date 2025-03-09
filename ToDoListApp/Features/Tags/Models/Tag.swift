//
//  Tag.swift
//  ToDoListApp
//
//  Created by Administrator on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - Tag Model
struct Tag: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var color: String
}
