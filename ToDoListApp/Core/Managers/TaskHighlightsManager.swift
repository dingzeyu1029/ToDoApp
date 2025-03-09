//
//  TaskHighlightsManager.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

@MainActor // Ensures all operations run on the main thread
final class TaskHighlightsManager: ObservableObject {
    @Published var highlights: String? = nil
    private var isLoading: Bool = false

    func loadAIHighlights(from tasks: [SingleCardData]) async {
        guard !tasks.isEmpty else {
            self.highlights = "You have no tasks to do. Enjoy your day!"
            return
        }

        guard !isLoading else { return } // Avoid duplicate calls
        isLoading = true

        do {
            let response = try await HighlightsGPT().fetchHighlights(tasks: tasks)
            if let aiHighlights = response {
                self.highlights = aiHighlights
            } else {
                self.highlights = "Unable to generate highlights at this time. Please try again later."
            }
        } catch {
            self.highlights = "An error occurred while fetching highlights."
            print("Error: \(error)")
        }

        isLoading = false
    }
}
