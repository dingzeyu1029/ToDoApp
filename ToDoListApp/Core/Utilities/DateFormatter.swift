//
//  DateFormatter.swift
//  ToDoListApp
//
//  Created by Dingze on 1/14/25.
//

import Foundation
import SwiftUI

extension DateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension Animation {
    static var appDefault: Animation {
        .spring(duration: 0.3)
    }
    
    static var snappy: Animation {
        .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.1)
    }
}
