//
//  AddTaskGPT.swift
//  ToDoListApp
//
//  Created by Dingze on 1/19/25.
//

import Foundation

struct AddTaskGPT {
    private let apiKey = "API_KEY"
    private let url = "URL"
    
    func fetchResponse(prompt: String, tags: [String], completion: @escaping ([String: Any]?) -> Void) {
        guard let endpoint = URL(string: url) else { return }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let currentDateString = DateFormatter.shared.string(from: Date())

        let tagList = tags.joined(separator: ", ")
        let systemPrompt = """
        You are a task assistant. Your job is to parse task details like task_name, time, tag, description, and subtasks (if specified by the user or if 
        the task can be divided into smaller actionable subtasks). from the input.
        Today’s date is \(currentDateString).
        Here are the existing tags: \(tagList).
        - Assign one of these tags if it matches the task content.
        - If no existing tag fits and you believe a new tag is necessary, suggest a tag name and a color. Ensure the tag is concise and relevant.
        - Avoid suggesting new tags if the task can be categorized under an existing one.
        Respond in JSON like:
        {
          "task_name": "<task>",
          "time": "<time>",
          "tag": "<tag>",
          "description": "<description>"
          "subtasks": ["<subtask 1>", "<subtask 2>", "..."]
        }.
        Use the time format: "MMM d, yyyy h:mm a" (e.g., Jan 20, 2025 8:00 AM).
        """
        
        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 150
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                completion(nil)
                return
            }
            
            if let response = try? JSONDecoder().decode(OpenAIResponse.self, from: data),
               let jsonString = response.choices.first?.message.content {
                print("Raw GPT Response: \(jsonString)")
                if let jsonData = jsonString.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    completion(jsonObject)
                } else {
                    print("Failed to parse JSON content: \(jsonString)")
                    completion(nil)
                }
            } else {
                print("Failed to decode OpenAIResponse: \(String(describing: String(data: data, encoding: .utf8)))")
                completion(nil)
            }
        }.resume()
    }
}

// Response model
struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
