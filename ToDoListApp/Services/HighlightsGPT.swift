//
//  HighlightsGPT.swift
//  ToDoListApp
//
//  Created by Dingze on 1/21/25.
//

import Foundation

struct HighlightsGPT {
    private let apiKey = "API_KEY"
    private let url = "URL"

    func fetchHighlights(tasks: [SingleCardData]) async throws -> String? {
        guard let endpoint = URL(string: url) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let taskSummaries = tasks.map { task in
            """
            - Title: \(task.title)
              Due: \(DateFormatter.shared.string(from: task.date))
              Tag: \(task.tag.name)
              Subtasks: \(task.subtasks.map { $0.title }.joined(separator: ", "))
              Completed: \(task.isChecked ? "Yes" : "No")
            """
        }.joined(separator: "\n")

        let currentDateString = DateFormatter.shared.string(from: Date())
        let prompt = """
        You are a task assistant summarizing a user's task list. Focus on simplicity, clarity, and brevity. Use a friendly and helpful tone.
        Here are the user's tasks: \(taskSummaries)
        Today’s date is \(currentDateString).
        Your goal:
        - Highlight overdue tasks (already past the deadline) and briefly mention their importance.
        - Based on deadlines, suggest which task should be prioritized.
        - Do not use markdown or unnecessary formatting as it will be displayed in plain text.
        - Respond concisely and avoid long explanations or overwhelming details.
        
        Respond in the following format with each section on a new line:
        
        Tasks: [Summary of overdue tasks].
        Priority Task: [Suggestion for the most urgent task].
        Reminders: [Additional important notes or tasks].

        Ensure each section is concise and clearly separated by line breaks.
        """

        let parameters: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are a task assistant."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 150
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

        // Perform the network request with `async/await`
        let (data, _) = try await URLSession.shared.data(for: request)

        // Decode the response
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return response.choices.first?.message.content
    }
}
